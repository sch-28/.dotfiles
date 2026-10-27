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
sudo pacman -S --needed bob feh rustup zsh tmux zoxide kitty stow polybar snixembed rofi kmonad python-i3ipc docker lazydocker nvm pulsemixer dunst xclip flameshot jre-openjdk dbeaver maven clamav redshift xorg-xsetroot nemo rofi-emoji harper 7zip gnome-keyring libsecret seahorse smartmontools

log "Install Hyprland + Dux (see hyprland-plan.md)"
sudo pacman -S --needed hyprland xdg-desktop-portal-hyprland quickshell matugen dux-gop wl-clipboard wtype satty gpu-screen-recorder jq playerctl
# dux-shell 2.0 is still only in extra-testing; switch to `pacman -S dux-shell` once it is in extra.
pacman -Q dux-shell >/dev/null 2>&1 || sudo pacman -U https://geo.mirror.pkgbuild.com/extra-testing/os/x86_64/dux-shell-2.0.0-1-x86_64.pkg.tar.zst || {
    echo "dux-shell install failed (URL moved? check extra / extra-testing)"; exit 1
}

log "snap-pac: snapshot / around every pacman transaction"
sudo pacman -S --needed snap-pac
sudo install -Dm644 ~/.dotfiles/snap-pac/etc/snap-pac.ini /etc/snap-pac.ini

log "Install dolphin (see kde/ stow package)"
# plasma-integration: platform theme plugin, without it Qt ignores kdeglobals and
# renders light. archlinux-xdg-menu: provides /etc/xdg/menus/arch-applications.menu,
# which XDG_MENU_PREFIX in zsh/.zprofile points kbuildsycoca6 at.
sudo pacman -S dolphin kio-extras kde-cli-tools plasma-integration archlinux-xdg-menu breeze breeze-icons ffmpegthumbs kdegraphics-thumbnailers gwenview

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
bash stow-all.sh

log "Mask kscreen"
# kded6 loading kscreen blanks both screens and crashes chromium under i3.
# Stow can't link /dev/null (absolute symlink), so mask here instead.
systemctl --user mask plasma-kscreen.service plasma-kscreen-osd.service

log "SSH agent"
systemctl --user enable gcr-ssh-agent.socket

log "Hyprland session units + Dux plugins"
systemctl --user add-wants hyprland-session.target dms.service
systemctl --user enable slack-alert-watch.service
dms plugins restore ~/.dotfiles/dms/plugins.lock.json

log "Rebuild KDE service cache"
# A cache built without XDG_MENU_PREFIX has zero apps in it and won't refresh on
# its own, since the source dirs' mtimes haven't changed. Drop it and rebuild.
rm -f ~/.cache/ksycoca6*
XDG_MENU_PREFIX=arch- kbuildsycoca6 --noincremental

log "Virus protection"
sudo systemctl enable --now clamav-freshclam.service

log "System health check"
sudo cp ~/.dotfiles/system-check/etc/systemd/system/system-check.service /etc/systemd/system/
sudo cp ~/.dotfiles/system-check/etc/systemd/system/system-check.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now system-check.timer

gpu=/sys/bus/pci/devices/0000:03:00.0
if [[ "$(cat $gpu/vendor $gpu/device 2>/dev/null)" == $'0x1002\n0x7550' ]]; then
    log "GPU: stable dGPU name + X on the dGPU"
    # Copied, not stowed: udev reads rules before /home is mounted.
    sudo install -Dm644 ~/.dotfiles/gpu/etc/udev/rules.d/90-rx9070.rules /etc/udev/rules.d/90-rx9070.rules
    sudo install -Dm644 ~/.dotfiles/gpu/etc/X11/xorg.conf.d/20-dgpu.conf /etc/X11/xorg.conf.d/20-dgpu.conf
    sudo udevadm control --reload
    sudo udevadm trigger --subsystem-match=drm --action=change
fi

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
