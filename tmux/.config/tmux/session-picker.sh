#!/usr/bin/env bash
PROJECT_DIR=~/.config/tmux/sessions

# Let user pick a script
SCRIPT=$(ls "$PROJECT_DIR"/*.sh | xargs -n 1 basename | fzf --prompt="Select project: ")

# If they picked something
if [ -n "$SCRIPT" ]; then
    # Start it in a new tmux window
    "$PROJECT_DIR/$SCRIPT"
fi
