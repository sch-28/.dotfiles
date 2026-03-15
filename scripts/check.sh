#!/usr/bin/env bash
# system-check.sh — passive system health check (Btrfs + NVMe + RAM/MCE + kernel logs)
# Designed to run as a systemd timer; output cached for shell login display.
# Optional: set NVME_DEV=/dev/nvme0n1  (or another device)
set -uo pipefail

CACHE_FILE="/tmp/system-check.log"
# Ensure cache file is writable by all (root creates it, user reads it)
install -m 666 /dev/null "$CACHE_FILE" 2>/dev/null || true
green='\033[0;32m'; yellow='\033[0;33m'; red='\033[0;31m'; reset='\033[0m'
ok="${green}OK${reset}"; warn="${yellow}WARN${reset}"; bad="${red}FAIL${reset}"

hr() { printf '%s\n' "----------------------------------------"; }

# ── Btrfs ──────────────────────────────────────────────────────────────

sum_btrfs_stats() {
  local mnt="$1"
  btrfs device stats "$mnt" 2>/dev/null \
    | awk '{s+=$2} END{print s+0}' 2>/dev/null || true
}

print_btrfs_block() {
  local mnt="$1"
  if ! command -v btrfs >/dev/null 2>&1; then
    printf "Btrfs %-6s [%b] btrfs-progs not installed\n" "$mnt" "$warn"
    return 0
  fi
  local sum
  sum="$(sum_btrfs_stats "$mnt")"
  if [[ -z "$sum" ]]; then
    printf "Btrfs %-6s [%b] cannot read device stats\n" "$mnt" "$warn"
  elif [[ "$sum" == "0" ]]; then
    printf "Btrfs %-6s [%b]  device stats: 0 errors\n" "$mnt" "$ok"
  else
    printf "Btrfs %-6s [%b] device stats: %s errors (run: btrfs device stats %s)\n" "$mnt" "$bad" "$sum" "$mnt"
  fi
}

print_all_btrfs() {
  # Deduplicate by source device — subvolumes on the same partition
  # share the same device stats, so we only need to check once per device.
  # We pick the shortest mount point per device (e.g., "/" over "/var/log").
  local found=0
  while IFS=' ' read -r _src mnt; do
    [[ -z "$mnt" ]] && continue
    found=1
    print_btrfs_block "$mnt"
  done < <(findmnt -rno SOURCE,TARGET -t btrfs 2>/dev/null \
    | sed 's/\[.*\]//' \
    | sort -t' ' -k1,1 -k2,2 \
    | awk -F' ' '!seen[$1]++')
  if [[ "$found" == 0 ]]; then
    printf "Btrfs        [%b] no btrfs mounts found\n" "$warn"
  fi
}

# ── Kernel journal ─────────────────────────────────────────────────────

kernel_storage_warnings_count() {
  local log count
  log="$(journalctl -b -p warning..alert --no-pager 2>/dev/null)" || true
  count="$(grep -Ei 'btrfs|nvme|I/O error|corrupt|timeout|reset' <<<"$log" \
    | grep -Evc 'unchecked data buffer|nfsrahead')" || true
  printf '%s' "${count:-0}"
}

print_kernel_block() {
  local c
  c="$(kernel_storage_warnings_count)"
  if [[ "$c" == "0" ]]; then
    printf "Kernel logs  [%b]  no storage warnings this boot\n" "$ok"
  else
    printf "Kernel logs  [%b] %s storage-related warning(s) this boot\n" "$warn" "$c"
    printf "  Hint: journalctl -b -p warning..alert | grep -Ei 'btrfs|nvme|I/O error|corrupt|timeout|reset'\n"
  fi
}

# ── NVMe SMART ─────────────────────────────────────────────────────────

print_nvme_block() {
  local dev="${NVME_DEV:-}"

  # Auto-pick first NVMe namespace if not provided
  if [[ -z "$dev" ]]; then
    for d in /dev/nvme*n1; do
      [[ -e "$d" ]] && dev="$d" && break
    done
  fi

  if [[ -z "$dev" || ! -e "$dev" ]]; then
    printf "NVMe SMART   [%b] no NVMe device found\n" "$warn"
    return 0
  fi

  if ! command -v smartctl >/dev/null 2>&1; then
    printf "NVMe SMART   [%b] smartmontools not installed\n" "$warn"
    return 0
  fi

  local out health crit used media errs temp
  out="$(smartctl -a "$dev" 2>/dev/null || true)"

  if [[ -z "$out" ]]; then
    printf "NVMe SMART   [%b] cannot read SMART for %s\n" "$warn" "$dev"
    return 0
  fi

  # Parse SMART fields — use $NF (last field) for robustness across formats
  health="$(grep -m1 -Ei 'overall-health' <<<"$out" | sed -E 's/.*result: *//' || true)"
  crit="$(grep -m1 -E '^Critical Warning:' <<<"$out" | awk '{print $NF}' || true)"
  used="$(grep -m1 -E '^Percentage Used:' <<<"$out" | awk '{print $NF}' | tr -d '%' || true)"
  media="$(grep -m1 -E '^Media and Data Integrity Errors:' <<<"$out" | awk '{print $NF}' || true)"
  errs="$(grep -m1 -E '^Error Information Log Entries:' <<<"$out" | awk '{print $NF}' || true)"
  temp="$(grep -m1 -E '^Temperature:' <<<"$out" | awk '{print $2}' || true)"

  # Derive health from Critical Warning if overall-health line is absent
  # (some NVMe drives / smartctl versions don't print it)
  if [[ -z "$health" ]]; then
    if [[ "${crit:-0}" == "0x00" || "${crit:-0}" == "0" ]]; then
      health="PASSED"
    else
      health="FAILED"
    fi
  fi

  local sev="$ok"
  if [[ "${health^^}" != "PASSED" ]]; then sev="$bad"; fi
  if [[ "${crit:-0}" != "0x00" && "${crit:-0}" != "0" ]]; then sev="$bad"; fi
  if [[ "${media:-0}" != "0" ]]; then sev="$bad"; fi

  printf "NVMe SMART   [%b] %s (temp=%s C, used=%s%%, media_err=%s, errlog=%s) [%s]\n" \
    "$sev" "${health:-unknown}" "${temp:-?}" "${used:-?}" "${media:-?}" "${errs:-?}" "$dev"
}

# ── RAM / MCE ──────────────────────────────────────────────────────────

print_ram_block() {
  # MCE (machine check exceptions) — hardware error reports from CPU/memory
  local mce_count=0
  if command -v journalctl >/dev/null 2>&1; then
    local log
    log="$(journalctl -b -p err..alert --no-pager 2>/dev/null)" || true
    mce_count="$(grep -Eci 'mce|machine.check.exception|memory error|hardware error|edac.*error' <<<"$log")" || true
    mce_count="${mce_count:-0}"
  fi

  if [[ "$mce_count" == "0" ]]; then
    printf "RAM/MCE      [%b]  no memory errors this boot\n" "$ok"
  else
    printf "RAM/MCE      [%b] %s memory/MCE error(s) this boot\n" "$bad" "$mce_count"
    printf "  Hint: journalctl -b | grep -Ei 'mce|machine check|memory error|edac'\n"
  fi

  # Basic meminfo summary
  if [[ -f /proc/meminfo ]]; then
    local total avail
    total="$(awk '/^MemTotal:/ {printf "%.1f", $2/1048576}' /proc/meminfo)"
    avail="$(awk '/^MemAvailable:/ {printf "%.1f", $2/1048576}' /proc/meminfo)"
    printf "RAM usage    [%b]  %s / %s GB available\n" "$ok" "$avail" "$total"
  fi
}

# ── Snapper ─────────────────────────────────────────────────────────────

print_snapper_block() {
  if ! command -v snapper >/dev/null 2>&1; then
    printf "Snapshots    [%b] snapper not installed\n" "$warn"
    return 0
  fi

  local configs
  configs="$(snapper list-configs 2>/dev/null | awk 'NR>2 {print $1}')" || true
  if [[ -z "$configs" ]]; then
    printf "Snapshots    [%b] no snapper configs found\n" "$warn"
    return 0
  fi

  local now max_age_hours
  now="$(date +%s)"
  max_age_hours=24

  while IFS= read -r cfg; do
    [[ -z "$cfg" ]] && continue
    # Get the date of the most recent snapshot (last non-empty line)
    local latest_date latest_ts age_hours
    latest_date="$(LC_ALL=C snapper -c "$cfg" list --columns date 2>/dev/null \
      | tail -n1 | xargs)" || true

    if [[ -z "$latest_date" ]]; then
      printf "Snapper %-4s [%b] no snapshots found\n" "$cfg" "$bad"
      continue
    fi

    latest_ts="$(LC_ALL=C date -d "$latest_date" +%s 2>/dev/null)" || true
    if [[ -z "$latest_ts" ]]; then
      printf "Snapper %-4s [%b] cannot parse date: %s\n" "$cfg" "$warn" "$latest_date"
      continue
    fi

    age_hours=$(( (now - latest_ts) / 3600 ))

    if [[ "$age_hours" -gt "$max_age_hours" ]]; then
      printf "Snapper %-4s [%b] latest snapshot is %sh old (%s)\n" "$cfg" "$bad" "$age_hours" "$latest_date"
    else
      printf "Snapper %-4s [%b] latest snapshot %sh ago (%s)\n" "$cfg" "$ok" "$age_hours" "$latest_date"
    fi
  done <<<"$configs"
}

# ── Main ───────────────────────────────────────────────────────────────

main() {
  {
    printf "=== System Health Check ===\n"
    printf "  %s\n" "$(date '+%Y-%m-%d %H:%M:%S')"
    hr
    print_all_btrfs
    hr
    print_nvme_block
    hr
    print_ram_block
    hr
    print_kernel_block
    hr
    print_snapper_block
    hr
  } | tee "$CACHE_FILE"
}

main "$@"
