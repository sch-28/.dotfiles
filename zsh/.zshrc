# Prioritize custom xdg-open first
export PATH="$HOME/.local/xdg-open:$HOME/bin:$HOME/.local/share/bob/nvim-bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Flatpak apps
export PATH="$PATH:/home/jan/.local/share/flatpak/exports/bin"

# Node.js (nvm)
export PATH="$HOME/.nvm/versions/node/v22.14.0/bin:$PATH"

# PKG config
export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig

# export TERM=tmux-256color

 ZVM_INIT_MODE=sourcing
# export __GLX_VENDOR_LIBRARY_NAME=nvidia


# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"


ZSH_THEME="agnoster"
ENABLE_CORRECTION="false"
zstyle ':omz:plugins:nvm' lazy yes
# plugins=(nvm git zsh-autosuggestions zsh-vi-mode)
plugins=(nvm git zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh


# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi



alias envim="cd ~/.dotfiles/nvim/.config/nvim && nvim"
alias ei3="cd ~/.dotfiles/i3/.config/i3 && nvim config"
alias ai="docker exec -it ollama ollama run deepseek-r1"
alias aiq="docker exec -it ollama ollama run deepseek-r1 --think=false"




export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border top'

# pnpm
export PNPM_HOME="/home/jan/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export NODE_OPTIONS="--max-old-space-size=16384"



eval "$(zoxide init zsh)"

eval "$(ssh-agent -s)" > /dev/null

# Only add SSH key if not already added
if ! ssh-add -l | grep -q "id_rsa_github"; then
    ssh-add ~/.ssh/id_rsa_github > /dev/null 2>&1
fi

# for fkc nova
export SKIP_POSTINSTALL="true"
# bun completions
[ -s "/home/jan/.bun/_bun" ] && source "/home/jan/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


 # ripgrep->fzf->vim [QUERY]
sf() (
  RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            nvim {1} +{2}     # No selection. Open the current line in Vim.
          else
            nvim +cw -q {+f}  # Build quickfix list for the selected items.
          fi'
  fzf --disabled --ansi --multi \
      --bind "start:$RELOAD" --bind "change:$RELOAD" \
      --bind "enter:become:$OPENER" \
      --bind "ctrl-o:execute:$OPENER" \
      --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
      --delimiter : \
      --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)' \
      --query "$*"
)


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source ~/.fzf.zsh
source <(fzf --zsh)


# (cat ~/.cache/wal/sequences &)

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# main_session_exists=false
# if tmux has-session -t main 2>/dev/null; then
#     main_session_exists=true
# fi
#
# kitty_count=$(ps aux | grep kitty | wc -l)
#
# # auto-start tmux unless already inside tmux
# if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
#
# if $main_session_exists && [ $kitty_count -eq 3 ]; then
#       tmux attach -t main
#   elif ! $main_session_exists; then
#         tmux new -s main
#   fi
# fi
