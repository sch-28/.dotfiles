#!/usr/bin/env bash
 DIRS=(
    "$HOME/work/dev"
    "$HOME/dev"
)

# Let user pick a script

 if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find  "${DIRS[@]}" -mindepth 1 -maxdepth 1 -type d \
        | sed "s|^$HOME/||" \
        | fzf --prompt="Select project: ")

    [[ $selected ]] && selected="$HOME/$selected"
fi

[[ ! $selected ]] && exit 0

selected_name=$(basename "$selected" | tr . _)

if ! tmux has-session -t "$selected_name"; then
    tmux new-session -ds "$selected_name" -c "$selected"
    tmux select-window -t "$selected_name:1"
fi

tmux switch-client -t "$selected_name"
