#!/usr/bin/env bash

# Get active window ID
active_win=$(xprop -root _NET_ACTIVE_WINDOW | awk -F ' # ' '{print $2}')
[ -z "$active_win" ] && exit 0

# Get PID from _NET_WM_PID
pid=$(xprop -id "$active_win" _NET_WM_PID 2>/dev/null | awk '{print $3}')
[ -z "$pid" ] && pid="?"


echo $pid
