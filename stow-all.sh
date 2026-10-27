#!/bin/bash

# Go to dotfiles root (optional, in case it's run from elsewhere)
cd "$(dirname "$0")"

# Explicit list: other top-level dirs (agents, nix, scripts, ...) aren't $HOME mirrors.
# ly targets / and is stowed separately with sudo (see install.sh).
packages=(
    bin
    claude
    dunst
    flameshot
    i3
    i3status
    kde
    kitty
    kmonad
    mime
    newsboat
    nvim
    nvim-old
    picom
    pipewire
    polybar
    retroarch
    rofi
    spotify
    sway
    tmux
    xdg-desktop-portal
    zsh
)

# Programs write their own files into these dirs (systemctl enable -> *.wants/,
# dms setup fragments, Dux plugins/state), so link per file instead of folding the
# whole dir into the repo.
no_fold=(
    dms
    hypr
    systemd
)

stow "${packages[@]}"
stow --no-folding "${no_fold[@]}"
