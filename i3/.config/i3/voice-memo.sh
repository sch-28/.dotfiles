#!/bin/bash

SCRIPT_PATH="/home/jan/dev/dict/src/main.ts"
BUN="/home/jan/.bun/bin/bun"


notify-send "Toggling recording" -t 500
"$BUN" "$SCRIPT_PATH"
