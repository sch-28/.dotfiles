#!/bin/sh
# Start/stop gpu-screen-recorder on the focused monitor with desktop audio.
# SIGINT is its "stop and finish the file" signal; mkv stays playable if it dies anyway.
set -u

RUNDIR="${XDG_RUNTIME_DIR:-/tmp}"
PIDFILE="$RUNDIR/record.pid"

# Only signal here: the recorder ignores SIGINT while still starting up, so the
# instance that started it owns the pidfile and reports once it really exits.
if [ -s "$PIDFILE" ] && kill -INT "$(cat "$PIDFILE")" 2>/dev/null; then
    exit 0
fi

exec 9>"$RUNDIR/record.lock"
flock -n 9 || exit 0

mon=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
out="$HOME/Videos/rec-$(date +%F_%H-%M-%S).mkv"
mkdir -p "$HOME/Videos"
gpu-screen-recorder -w "$mon" -f 60 -a default_output -c mkv -o "$out" 9>&- &
echo $! >"$PIDFILE"
notify-send -a "Screen recording" "Recording $mon"
if wait $!; then
    notify-send -a "Screen recording" "Saved to ~/Videos/$(basename "$out")"
else
    notify-send -u critical -a "Screen recording" "Recorder exited with $? on '$mon'"
fi
rm -f "$PIDFILE"
