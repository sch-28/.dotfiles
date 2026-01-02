#!/bin/bash
log ()
{
    echo "[INFO] $1"
}

error() {
    echo "[ERROR] $1"
    exit 1
}

prompt() {
    read -p "$1 (y/n): " response
    case "$response" in
        [Yy]* ) return 0;;  # User wants to proceed
        [Nn]* ) return 1;;  # User does not want to proceed
        * ) echo "Please answer y or n." && prompt "$1" ;;  # Ask again
    esac
}

log "Running full update"
bash ./update.sh

log "Install required pacman packages"
sudo pacman -S bob feh rustup zsh tmux zoxide kitty stow polybar rofi kmonad python-i3ipc docker lazydocker nvm pulsemixer dunst xclip flameshot jre-openjdk dbeaver maven clamav redshift xorg-xsetroot

log "Install required yay packages"
yay -S greenclip

log "Install node"
nvm install 22.14
npm i -g bun@1.2.23

log "Install neovim"
bob install nightly
bob use nightly

log "Install antigen"
curl -L git.io/antigen > ~/.antigen.zsh

log "Stow all dotfiles"
sudo bash stow-all.sh

log "Virus protection"
sudo systemctl enable --now clamav-freshclam.service

if prompt "Do you want to install ly?"; then
    log "Download ly"
    sudo pacman -S ly
    log "Remove initial ly config"
    sudo rm -rf /etc/ly/config.ini
    sudo stow -t / ly
    sudo systemctl enable ly@tty1.service
    sudo systemctl disable getty@tty1.service
    sudo systemctl disable lightdm && sudo systemctl stop lightdm
fi
