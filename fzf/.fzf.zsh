# Setup fzf
# ---------
if [[ ! "$PATH" == */home/jan/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/jan/.fzf/bin"
fi

source <(fzf --zsh)
