#!/bin/sh
# Beep until the Slack notification is closed, Slack gets focus, or MAX seconds pass.
# $1 = notification ID, $2 = closes recorded before it (IDs restart from 1 when dms
# restarts, so only later closes count; counted by the watcher so none slip past).
set -u

ID="$1"
SEEN="$2"
SOUND="$(dirname "$(readlink -f "$0")")/slack-alert.wav"
MAX=30
GAP=0.3
RUNDIR="${XDG_RUNTIME_DIR:-/tmp}"
CLOSED="$RUNDIR/slack-alert.closed"
LOG="$RUNDIR/slack-alert.log"

log() { echo "$(date +%T) [$ID] $*" >>"$LOG"; }

# A burst of Slack messages should not stack overlapping loops.
exec 9>"$RUNDIR/slack-alert.lock"
flock -n 9 || { log "skip: another loop already running"; exit 0; }
log "start"

slack_focused() { hyprctl activewindow -j 2>/dev/null | grep -qi '"class": *"slack"'; }
closed() { tail -n +"$((SEEN + 1))" "$CLOSED" 2>/dev/null | grep -qx "$ID"; }

# If Slack already had focus, focus says nothing about whether you reacted.
started_in_slack=0
slack_focused && started_in_slack=1

pw-play "$SOUND" 2>/dev/null
end=$(($(date +%s) + MAX))
while [ "$(date +%s)" -lt "$end" ]; do
    if closed; then log "stop: notification closed"; exit 0; fi
    if [ "$started_in_slack" = 0 ] && slack_focused; then log "stop: Slack focused"; exit 0; fi
    sleep "$GAP"
    pw-play "$SOUND" 2>/dev/null
done
log "stop: hit SLACK_ALERT_MAX (${MAX}s)"
