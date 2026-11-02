#!/bin/bash
# Personal statusline: the caveman badge, plus a local log of quota changes for fluss usage (FLUSS-86).
# The work account shares the hooks dir, so the log is written only for the personal config.
input=$(cat)
printf '%s' "$input" | bash "$HOME/.claude/hooks/caveman-statusline.sh"

[ "${CLAUDE_CONFIG_DIR:-}" = "$HOME/.claude-personal" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

snapshot=$(printf '%s' "$input" | jq -c '
	select(.rate_limits.five_hour or .rate_limits.seven_day)
	| {
		five_hour: (.rate_limits.five_hour // null | if . then {used_percentage, resets_at} else null end),
		seven_day: (.rate_limits.seven_day // null | if . then {used_percentage, resets_at} else null end),
		model: (.model.id // null)
	}' 2>/dev/null) || exit 0
[ -n "$snapshot" ] || exit 0

dir="$HOME/.claude-personal/fluss"
last="$dir/.rate-limits-last"
mkdir -p "$dir"
# The log holds changes only; this mtime says the values were still current at the last render (FLUSS-43).
touch "$dir/.rate-limits-seen"
[ -f "$last" ] && [ "$(cat "$last")" = "$snapshot" ] && exit 0
printf '%s' "$snapshot" >"$last"
printf '%s' "$snapshot" | jq -c --arg ts "$(date -u +%FT%TZ)" '{ts: $ts} + .' >>"$dir/rate-limits.jsonl"
