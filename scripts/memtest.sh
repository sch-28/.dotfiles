#!/usr/bin/env bash
# memtest.sh — active RAM health test via memtester
#
# Unlike check.sh (passive: reads SMART/journal/MCE counters), this ACTIVELY
# exercises RAM by writing test patterns and reading them back, catching bit
# errors that passive monitoring misses.
#
# Caveat: memtester only tests memory it can ALLOCATE in userspace. It cannot
# test RAM currently held by the kernel or other processes. For full coverage
# of every byte, run memtest86+ from the bootloader (no OS competing for RAM).
#
# Usage:
#   memtest.sh                # auto-size (most of free RAM), 1 run
#   memtest.sh 4G             # test 4 GB
#   memtest.sh 4G 3          # test 4 GB, 3 runs
#   memtest.sh -y            # skip confirmation prompt
#   sudo memtest.sh          # recommended: lets memtester mlock the region
#
set -uo pipefail

green='\033[0;32m'; yellow='\033[0;33m'; red='\033[0;31m'; reset='\033[0m'
ok="${green}OK${reset}"; warn="${yellow}WARN${reset}"; bad="${red}FAIL${reset}"
hr() { printf '%s\n' "----------------------------------------"; }

ASSUME_YES=0
ARGS=()
for a in "$@"; do
  case "$a" in
    -y|--yes) ASSUME_YES=1 ;;
    -h|--help)
      sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) ARGS+=("$a") ;;
  esac
done

SIZE_ARG="${ARGS[0]:-}"
RUNS="${ARGS[1]:-1}"

# ── Preconditions ───────────────────────────────────────────────────────

if ! command -v memtester >/dev/null 2>&1; then
  printf "memtester    [%b] not installed (Arch: sudo pacman -S memtester)\n" "$bad"
  exit 1
fi

# ── Sizing ──────────────────────────────────────────────────────────────
# memtester mlocks the region; testing too much forces swap or the OOM killer.
# Default: test MemAvailable minus a safety reserve (max of 2 GB or 10% total).

total_mb="$(awk '/^MemTotal:/     {printf "%d", $2/1024}' /proc/meminfo)"
avail_mb="$(awk '/^MemAvailable:/ {printf "%d", $2/1024}' /proc/meminfo)"

if [[ -n "$SIZE_ARG" ]]; then
  test_size="$SIZE_ARG"
else
  reserve_mb=$(( total_mb / 10 ))
  (( reserve_mb < 2048 )) && reserve_mb=2048
  test_mb=$(( avail_mb - reserve_mb ))
  if (( test_mb < 256 )); then
    printf "memtester    [%b] only %sMB available after %sMB reserve — too little to test safely\n" \
      "$bad" "$((avail_mb - reserve_mb < 0 ? 0 : avail_mb - reserve_mb))" "$reserve_mb"
    printf "  Free up RAM, or pass an explicit size: memtest.sh 1G\n"
    exit 1
  fi
  test_size="${test_mb}M"
fi

# ── Pre-flight report ─────────────────────────────────────────────────────

printf "=== Active RAM Health Test ===\n"
printf "  %s\n" "$(date '+%Y-%m-%d %H:%M:%S')"
hr
printf "RAM total    %s MB\n" "$total_mb"
printf "RAM avail    %s MB\n" "$avail_mb"
printf "Test size    %s\n" "$test_size"
printf "Runs         %s\n" "$RUNS"

if [[ "$(id -u)" != "0" ]]; then
  printf "Privileges   [%b] not root — memtester cannot mlock; pages may swap and weaken the test\n" "$warn"
  printf "             Re-run with: sudo %s %s\n" "$0" "${ARGS[*]}"
else
  printf "Privileges   [%b] root — region will be locked into RAM (mlock)\n" "$ok"
fi
hr

# ── Confirm ───────────────────────────────────────────────────────────────
# Active test saturates RAM and is slow (minutes to hours for large sizes).

if [[ "$ASSUME_YES" != "1" ]]; then
  printf "This will allocate %s and stress it hard. Machine may feel sluggish.\n" "$test_size"
  read -r -p "Proceed? [y/N] " reply
  case "$reply" in
    [yY]|[yY][eE][sS]) ;;
    *) printf "Aborted.\n"; exit 0 ;;
  esac
  hr
fi

# ── Run ─────────────────────────────────────────────────────────────────

printf "Running memtester...\n\n"
memtester "$test_size" "$RUNS"
rc=$?

hr
if [[ "$rc" == "0" ]]; then
  printf "Result       [%b] all patterns passed — no RAM errors detected in tested region\n" "$ok"
  printf "  Note: only tested userspace-allocatable RAM. For every byte, run memtest86+ at boot.\n"
else
  printf "Result       [%b] memtester reported errors (exit %s) — likely bad RAM\n" "$bad" "$rc"
  printf "  Next: reseat/swap DIMMs, run memtest86+ at boot to confirm and locate the module.\n"
fi
exit "$rc"
