#!/bin/sh
set -u

SOUND="${SLACK_ALERT_SOUND:-$HOME/.config/dunst/sound.wav}"
MAX="${SLACK_ALERT_MAX:-30}"
GAP="${SLACK_ALERT_GAP:-0.3}"
IGNORE_FOCUS="${SLACK_ALERT_IGNORE_FOCUS:-0}"
RUNDIR="${XDG_RUNTIME_DIR:-/tmp}"
LOCK="$RUNDIR/slack-alert.lock"
LOG="$RUNDIR/slack-alert.log"

log() { echo "$(date +%T) $*" >>"$LOG"; }

: >"$LOG"
log "start: ${2:-<no summary>}"

# Single instance: a burst of five Slack messages should not stack five
# overlapping loops. If one is already running it has already got the attention.
exec 9>"$LOCK"
flock -n 9 || { log "stop: another loop already running"; exit 0; }

focused_class() { xdotool getactivewindow getwindowclassname 2>/dev/null; }

slack_focused() {
    [ "$IGNORE_FOCUS" = 1 ] && return 1
    focused_class | grep -qi slack
}

displayed() {
    n=$(dunstctl count displayed 2>/dev/null) || return 1
    case "$n" in ''|*[!0-9]*) return 1 ;; esac
    [ "$n" -gt 0 ]
}

# If Slack already had focus, focus tells us nothing about whether you reacted,
# so the focus check below is disabled for this run.
started_in_slack=0
if slack_focused; then
    started_in_slack=1
    log "note: Slack already focused -- focus ignored as an ack for this run"
fi

# First hit goes out before any check -- dunst may not have painted the
# notification yet, and this one is the one that wakes the amp anyway.
pw-play "$SOUND" 2>/dev/null

end=$(($(date +%s) + MAX))
while [ "$(date +%s)" -lt "$end" ]; do
    if ! displayed; then log "stop: notification dismissed"; exit 0; fi
    if [ "$started_in_slack" = 0 ] && slack_focused; then
        log "stop: focus moved to Slack"; exit 0
    fi
    sleep "$GAP"
    pw-play "$SOUND" 2>/dev/null
done
log "stop: hit SLACK_ALERT_MAX (${MAX}s)"
