# Prioritize custom xdg-open first
export PATH="$HOME/.local/xdg-open:$HOME/bin:$HOME/.local/share/bob/nvim-bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Flatpak apps
export PATH="$PATH:/home/jan/.local/share/flatpak/exports/bin"

# Cargo apps
export PATH="$HOME/.cargo/bin:$PATH"

# Node.js (nvm)
export PATH="$HOME/.nvm/versions/node/v22.14.0/bin:$PATH"

# PKG config
export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig



export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

export SUDO_EDITOR='/home/jan/.local/share/bob/nvim-bin/nvim'



alias envim="cd ~/.dotfiles/nvim/.config/nvim && nvim"
alias ei3="cd ~/.dotfiles/i3/.config/i3 && nvim config"
alias ai="docker exec -it ollama ollama run deepseek-r1"
alias aiq="docker exec -it ollama ollama run deepseek-r1 --think=false"

alias ls='ls --color=auto -hv -l'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -c=auto'


PS1='%F{blue}%B%~%b%f %F{gray}❯%f '

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000 
setopt inc_append_history




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

# bun completions
[ -s "/home/jan/.bun/_bun" ] && source "/home/jan/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export NVM_LAZY_LOAD=true


export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border top'
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

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# bundles
source ~/.antigen.zsh
antigen use oh-my-zsh  
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle git
antigen theme robbyrussell/oh-my-zsh themes/minimal
antigen bundle lukechilds/zsh-nvm
antigen apply 



if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux 
fi
