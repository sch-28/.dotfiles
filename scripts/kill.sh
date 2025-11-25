#!/usr/bin/env bash

# Get PID, PGID, and command
process_list=$(ps -eo pid,pgid,comm --no-headers | awk '$3!="["')

chosen=$(echo "$process_list" | rofi -dmenu -i -p "Kill process/group")

[ -z "$chosen" ] && exit 0

pid=$(echo "$chosen" | awk '{print $1}')
pgid=$(echo "$chosen" | awk '{print $2}')
cmd=$(echo "$chosen" | awk '{print $3}')

confirm=$(echo -e "Cancel\nKill only PID $pid\nKill process group $pgid" \
        | rofi -dmenu -i -p "$cmd (PID $pid, PGID $pgid)")

case "$confirm" in
    "Kill only PID $pid")
        kill "$pid"
        ;;

    "Kill process group $pgid")
        kill -TERM -- "-$pgid"

        # If still alive, offer SIGKILL
        sleep 0.2
        if ps -o pgid= -p "$pid" >/dev/null 2>&1; then
            force=$(echo -e "No\nYes" \
                | rofi -dmenu -i -p "Force kill group $pgid?")
            [ "$force" = "Yes" ] && kill -KILL -- "-$pgid"
        fi
        ;;
esac
