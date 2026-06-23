# ============================================================
#  PATH — typeset -U dedupes; guards keep it portable (Arch + NixOS).
#  Missing dirs are simply not added instead of erroring.
# ============================================================
typeset -U path

path=(
  "$HOME/.local/xdg-open"               # custom xdg-open first
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  $path
)

# bob-managed neovim — prepend so it wins, only if present (absent on NixOS).
[ -d "$HOME/.local/share/bob/nvim-bin" ]    && path=("$HOME/.local/share/bob/nvim-bin" $path)
[ -d "$HOME/.local/share/pnpm" ]            && path=("$HOME/.local/share/pnpm" $path)
[ -d "$HOME/.bun/bin" ]                      && path+=("$HOME/.bun/bin")
[ -d "$HOME/.local/share/flatpak/exports/bin" ] && path+=("$HOME/.local/share/flatpak/exports/bin")
[ -d "$HOME/.opencode/bin" ]                 && path+=("$HOME/.opencode/bin")

# Android SDK — only when configured.
if [ -d "$HOME/.config/android" ]; then
  export ANDROID_HOME="$HOME/.config/android"
  export ANDROID_SDK_ROOT="$HOME/.config/android"
  export CAPACITOR_ANDROID_STUDIO_PATH=/sbin/android-studio
  path+=("$ANDROID_HOME/platform-tools" "$ANDROID_HOME/emulator")
fi

export PATH

# ============================================================
#  Environment
# ============================================================
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"
export BROWSER='firefox'
export NODE_OPTIONS="--max-old-space-size=16384"
export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border top'

# Editor: nvim locally, vim over ssh.
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
command -v nvim >/dev/null && export SUDO_EDITOR="$(command -v nvim)"

# ============================================================
#  History
# ============================================================
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt inc_append_history      # write each command immediately
setopt share_history           # live-sync history across all open terminals
setopt hist_ignore_all_dups    # drop older duplicate of a repeated command
setopt hist_reduce_blanks      # trim surplus whitespace before saving

# ============================================================
#  Keymap — force emacs bindings. Without this zsh picks vi-insert mode
#  (because $EDITOR=nvim matches "vi"), which breaks Ctrl-F/Ctrl-A/Ctrl-E and
#  zsh-autosuggestions' accept-on-forward-char. oh-my-zsh used to set this.
# ============================================================
bindkey -e

# Word movement + line nav that oh-my-zsh used to provide. Without these the
# terminal's escape sequences (e.g. Ctrl-Right = ^[[1;5C) aren't bound and the
# trailing letter (C/D/A/B) gets inserted literally.
bindkey '^[[1;5C' forward-word        # Ctrl-Right
bindkey '^[[1;5D' backward-word       # Ctrl-Left
bindkey '^[[1;3C' forward-word        # Alt-Right
bindkey '^[[1;3D' backward-word       # Alt-Left
bindkey '^[[H'    beginning-of-line   # Home
bindkey '^[[F'    end-of-line         # End
bindkey '^[[1~'   beginning-of-line   # Home (alt encoding)
bindkey '^[[4~'   end-of-line         # End  (alt encoding)
bindkey '^[[3~'   delete-char         # Delete
bindkey '^[[3;5~' kill-word           # Ctrl-Delete
bindkey '^H'      backward-kill-word  # Ctrl-Backspace (some terminals)
bindkey '^[[1;5A' up-line-or-history    # Ctrl-Up
bindkey '^[[1;5B' down-line-or-history  # Ctrl-Down

# ============================================================
#  Prompt — minimal, no theme framework.
# ============================================================
PS1='%F{blue}%B%~%b%f %F{gray}❯%f '

# ============================================================
#  Completion (oh-my-zsh used to run this; do it ourselves).
#  Rebuild the dump at most once / 24h; otherwise load it cached (-C skips
#  the slow security rescan — completions still load fully, no power lost).
# ============================================================
autoload -Uz compinit
# Filename generation does NOT happen inside [[ ]], so glob the dump in an array
# assignment (where it does). Non-empty match => dump older than 24h => rebuild;
# otherwise load it cached with -C (skips the slow security rescan).
() {
  setopt localoptions extendedglob
  local -a stale=( ${ZDOTDIR:-$HOME}/.zcompdump(N.mh+24) )
  if (( $#stale )) || [[ ! -s ${ZDOTDIR:-$HOME}/.zcompdump ]]; then
    compinit
  else
    compinit -C
  fi
}

# ============================================================
#  Aliases
# ============================================================
alias ls='ls --color=auto -hv -l'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -c=auto'

alias envim="cd ~/.dotfiles/nvim/.config/nvim && nvim"
alias ei3="cd ~/.dotfiles/i3/.config/i3 && nvim config"
alias ai="docker exec -it ollama ollama run deepseek-r1"
alias aiq="docker exec -it ollama ollama run deepseek-r1 --think=false"

# git — common subset ported from the oh-my-zsh git plugin (no framework).
alias g='git'
alias gst='git status'
alias ga='git add'
alias gc='git commit -v'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias glog='git log --oneline --decorate --graph'

# NixOS — rebuild from ~/.dotfiles, auto-targeting this host (#desktop/laptop/surface).
# No-ops on Arch (nixos-rebuild absent). FLAKE points at the repo, runnable anywhere.
if command -v nixos-rebuild >/dev/null 2>&1; then
  FLAKE="$HOME/.dotfiles#$(hostnamectl --static 2>/dev/null || hostname)"
  alias nrs="sudo nixos-rebuild switch --flake $FLAKE"  # apply now + persist
  alias nrt="sudo nixos-rebuild test   --flake $FLAKE"  # try without a boot entry
  alias nrb="sudo nixos-rebuild boot   --flake $FLAKE"  # apply on next boot
  alias nro="sudo nixos-rebuild switch --rollback"      # roll back a generation
  alias nfu="nix flake update --flake $HOME/.dotfiles"  # bump inputs (re-lock)
  alias ngc="sudo nix-collect-garbage -d"               # delete old generations
  # dry validate a host without building: nrc desktop
  nrc() { nix eval ".#nixosConfigurations.${1:-$(hostname)}.config.system.build.toplevel.drvPath" >/dev/null && echo "ok: ${1:-$(hostname)}"; }
fi

# ============================================================
#  Tools
# ============================================================
eval "$(zoxide init zsh)"
source <(fzf --zsh)

# nvm — Arch keeps it in $HOME/.nvm (zsh-nvm) or /usr/share (pkg). Skipped on
# NixOS, which supplies node declaratively.
[ -r "$HOME/.nvm/nvm.sh" ]            && source "$HOME/.nvm/nvm.sh"
[ -r /usr/share/nvm/init-nvm.sh ]    && source /usr/share/nvm/init-nvm.sh
[ -s "$HOME/.bun/_bun" ]             && source "$HOME/.bun/_bun"   # bun completions

# Reuse a single ssh-agent across shells instead of spawning one each time.
SSH_AGENT_ENV="${XDG_RUNTIME_DIR:-/tmp}/ssh-agent.env"
if [ -z "$SSH_AUTH_SOCK" ]; then
  [ -r "$SSH_AGENT_ENV" ] && . "$SSH_AGENT_ENV" > /dev/null
  ssh-add -l > /dev/null 2>&1
  if [ $? -eq 2 ]; then
    ssh-agent -s > "$SSH_AGENT_ENV"
    . "$SSH_AGENT_ENV" > /dev/null
  fi
fi

# ripgrep -> fzf -> nvim  (sf [QUERY])
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

# Ctrl-X Ctrl-E: edit the current command line in $EDITOR.
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# ============================================================
#  Plugins — distro-packaged, sourced directly. NO antigen, no runtime
#  git-clone from GitHub at startup (that was the supply-chain hole).
#    Arch:  sudo pacman -S zsh-autosuggestions zsh-syntax-highlighting
#    NixOS: provided via home-manager / home.packages (nix-profile path)
#  syntax-highlighting MUST be sourced last.
# ============================================================
# NixOS: home-manager writes ~/.config/zsh/nix-plugins.zsh with exact store
# paths (autosuggestions then syntax-highlighting). Otherwise fall back to the
# distro-packaged paths (Arch). Either way syntax-highlighting is sourced last.
if [ -r "$HOME/.config/zsh/nix-plugins.zsh" ]; then
  source "$HOME/.config/zsh/nix-plugins.zsh"
else
  [ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  [ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ============================================================
#  Show system health check in the first tmux pane of each terminal.
# ============================================================
if [[ -n "$TMUX" ]] && [[ "$(tmux list-panes | wc -l)" == "1" ]] && [[ "$(tmux list-windows | wc -l)" == "1" ]] && [[ -r /run/system-check.log ]]; then
  cat /run/system-check.log
  echo
fi
