# User packages — mapped from the live Arch `pacman -Qe` list (365 explicit).
# Only real apps/tools live here; Arch base/libs/drivers became NixOS options
# (see common.nix / desktop.nix) and are NOT listed.
#
# Lines marked `# VERIFY` are <80%-confidence attr names — uncomment once a
# build confirms them. `nix eval` validates every active name without building.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # --- shell / terminal / cli (plocate via services.locate in common) ---
    btop htop glances inxi duf ncdu
    ripgrep fzf bat zoxide jq tmux
    ranger newsboat tldr stow
    pv pwgen rsync wget which unzip zip unrar

    # --- dev toolchains (Nix replaces nvm/bob/rustup version managers) ---
    git gh
    nodejs_22 bun cargo rustc
    jdk jdk21          # jdk25  # VERIFY (may be temurin-bin-25)
    maven
    clang lld cmake meson nasm
    pipx lazydocker
    python3Packages.i3ipc

    # --- system / disk / hardware utils (smartmontools via services.smartd) ---
    acpi alsa-utils brightnessctl
    dmidecode hdparm hwinfo lsscsi nvme-cli sg3_utils
    ethtool nmap dnsutils
    ddrescue memtester stress-ng sysstat sysfsutils mtools
    snapper
    clamav efitools
    glmark2 mesa-demos vulkan-tools nvtopPackages.full
    aspell aspellDicts.en
    ffmpegthumbnailer

    # --- X11 helpers ---
    xclip xcolor xbindkeys xss-lock numlockx dex xdotool
    libinput-gestures # config in wm.nix; autostarted via dex (.desktop in wm.nix)
    xorg.xdpyinfo xorg.xinput xorg.xkill xorg.xrandr
    xorg.xsetroot xorg.setxkbmap
    arandr lxappearance nwg-look

    # --- WM stack (i3 itself enabled in common.nix; these are the daemons) ---
    polybar rofi dunst picom
    i3blocks i3lock i3status
    dmenu rofi-emoji playerctl pulsemixer pavucontrol redshift
    flameshot feh

    # --- GUI apps ---
    firefox chromium
    kitty xfce.xfce4-terminal xterm
    vscode
    discord vesktop slack spotify
    obsidian
    bitwarden-desktop # EOL electron whitelisted in common.nix
    libreoffice-fresh
    gimp inkscape darktable blender freecad fontforge
    calibre mpv
    galculator gnome-calculator
    gparted gnome-disk-utility btrfs-assistant
    nemo xarchiver meld xfce.thunar
    kdePackages.dolphin kdePackages.gwenview
    mission-center
    xfce.xfce4-screensaver
    # xed-editor          # VERIFY attr name
    # bambu-studio        # VERIFY (3D printer slicer)
    # protonmail-desktop  # VERIFY attr name
    rustdesk

    # --- gaming / emulation (steam itself via programs.steam in common.nix) ---
    lutris protontricks winetricks
    wineWowPackages.staging
    mangohud
    retroarch ppsspp dolphin-emu dosbox

    # --- mobile/android ---
    android-tools
    android-studio

    # --- low-confidence / needs decision ---
    # hactool            # VERIFY (Switch NCA tool)
    # harper             # VERIFY (grammar checker / harper-ls)
    # fbset              # VERIFY
    # bolt-launcher      # VERIFY (RuneScape launcher)
    # NOT in nixpkgs (AUR-only) — use flatpak or VPN config instead:
    #   surfshark-client -> wireguard/openvpn config
    #   recordly-bin     -> obs-studio or flatpak
  ];
}
