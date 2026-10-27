#!/bin/sh
# Dux has no per-notification script hook (dunst's `script =`), so watch the bus:
# start slack-alert.sh for each Slack notification, record closed IDs for it to poll.
set -u

CLOSED="${XDG_RUNTIME_DIR:-/tmp}/slack-alert.closed"
ALERT="$(dirname "$(readlink -f "$0")")/slack-alert.sh"
: >"$CLOSED"

# The notification ID only comes back in Notify's reply, matched by caller + serial.
dbus-monitor --session \
    "type='method_call',interface='org.freedesktop.Notifications',member='Notify'" \
    "type='method_return',sender='org.freedesktop.Notifications'" \
    "type='signal',interface='org.freedesktop.Notifications',member='NotificationClosed'" |
awk -v alert="$ALERT" -v closed="$CLOSED" -v nclosed=0 '
    function field(name,   v) { match($0, name "=[^ ]+"); v = substr($0, RSTART, RLENGTH); sub(/^[^=]+=/, "", v); return v }
    /^method call /   { kind = "call";   key = field("sender") " " field(" serial"); line = 0; next }
    /^method return / { kind = "return"; key = field("destination") " " field("reply_serial"); line = 0; next }
    /^signal /        { kind = /member=NotificationClosed/ ? "closed" : ""; line = 0; next }
    { line++ }
    kind == "call"   && line == 1 && tolower($0) ~ /^ *string "slack"$/ { pending[key] = 1; next }
    kind == "return" && line == 1 && (key in pending) { delete pending[key]; system(alert " " $2 " " nclosed " &"); next }
    kind == "closed" && line == 1 { print $2 >> closed; fflush(closed); nclosed++ }
'
