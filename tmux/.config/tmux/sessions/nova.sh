#!/usr/bin/env bash

SESSION="nova"
ROOT=~/work/dev/fkc-nova
BACKOFFICE=~/work/dev/nova-backoffice

# Start postgres container before tmux session
docker start postgres >/dev/null 2>&1

# Check if session already exists
tmux has-session -t $SESSION 2>/dev/null
if [ $? -eq 0 ]; then
    if [ -n "$TMUX" ]; then
      tmux switch-client -t $SESSION
    else
      exec tmux attach -t $SESSION
    fi
fi

# Create new session
tmux new-session -d -s $SESSION -c "$ROOT" -n editor

# Window 1: editor
tmux send-keys -t $SESSION:editor 'nvim' C-m

# Window 2: fkc-nova
tmux new-window -t $SESSION -c "$ROOT" -n fkc-nova
tmux send-keys -t $SESSION:fkc-nova 'bun run dev' C-m

# Window 3: backoffice
tmux new-window -t $SESSION -c "$BACKOFFICE" -n backoffice
tmux send-keys -t $SESSION:backoffice 'mvn spring-boot:run' C-m

# Select editor window by default
tmux select-window -t $SESSION:editor

# Attach
 if [ -n "$TMUX" ]; then
  tmux switch-client -t $SESSION
else
  exec tmux attach -t $SESSION
fi
