# User packages — mapped from the live Arch `pacman -Qe` list.
# Two tiers, each package listed ONCE (DRY):
#   base  — always installed (i3 desktop + cli + light GUI). Fits the 4GB/64GB
#           Surface Go.
#   heavy — big GUI apps, toolchains, emulators. Skipped on lean hosts
#           (`my.lean = true`, e.g. surface) via osConfig.
#
# `# VERIFY` = <80%-confidence attr name; uncomment once a build confirms it.
{ pkgs, lib, osConfig, ... }:
let
  base = with pkgs; [
    # --- shell / terminal / cli (plocate via services.locate in common) ---
    btop htop glances inxi duf ncdu
    ripgrep fzf bat zoxide jq tmux
    ranger newsboat tldr stow
    pv pwgen rsync wget which unzip zip unrar
    neovim # your $EDITOR; config symlinked in terminal.nix
    git gh claude-code
    nodejs_22 pnpm # node ships npm/npx/corepack; pnpm separate
    (python3.withPackages (ps: with ps; [ i3ipc ])) # python3 + i3ipc; REQUIRED by i3 helper scripts (autotiling, firefox-launch, firefox-title, quick-launch)

    # --- nvim runtime deps (config in nvim/.config/nvim) ---
    cargo rustc          # blink.cmp `cargo build --release` on first launch
    gcc gnumake          # nvim-treesitter parser compilation; cargo native-dep builds
    tree-sitter          # satisfies plugins/treesitter.lua PATH check, skips cargo install
    prettier             # ALE fixer for js/ts/jsx/tsx (plugins/ale.lua)
    harper               # harper_ls grammar checker (lsp.lua)
    lua-language-server  # lua_ls (mason's prebuilt binary breaks on NixOS — exit 127)

    # --- system / disk / hardware utils (smartmontools via services.smartd) ---
    psmisc # killall, pstree, fuser (procps ships pkill but not killall)
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
    xdpyinfo xinput xkill xrandr xsetroot setxkbmap xprop
    arandr lxappearance nwg-look

    # --- WM stack (i3 enabled in common.nix; these are the daemons) ---
    polybar rofi dunst picom
    i3blocks i3lock i3status
    dmenu rofi-emoji playerctl pulsemixer pavucontrol redshift
    flameshot feh

    # --- light GUI (browser, terminal, file manager, small utils) ---
    firefox firefox-devedition
    kitty xfce4-terminal xterm
    nemo xarchiver meld
    galculator gnome-calculator
    gparted gnome-disk-utility btrfs-assistant
    mission-center
    xfce4-screensaver
  ];

  # Skipped on lean hosts (surface). Big downloads / heavy at runtime.
  heavy = with pkgs; [
    # --- dev toolchains (Nix replaces nvm/bob/rustup; node/pnpm/cargo/rustc moved to base for nvim) ---
    bun cargo-audit
    jdk jdk21          # jdk25  # VERIFY (may be temurin-bin-25)
    maven
    clang lld cmake meson nasm
    pipx lazydocker

    # --- heavy GUI apps ---
    chromium
    vscode
    discord vesktop slack spotify
    obsidian
    bitwarden-desktop # EOL electron whitelisted in common.nix
    libreoffice-fresh
    gimp inkscape darktable blender freecad fontforge
    calibre mpv
    thunar
    kdePackages.dolphin kdePackages.gwenview
    rustdesk vokoscreen-ng
    # xed-editor          # VERIFY attr name
    # bambu-studio        # VERIFY (3D printer slicer)
    # protonmail-desktop  # VERIFY attr name

    # --- gaming / emulation (steam via programs.steam in workstation.nix) ---
    lutris protontricks winetricks
    wineWow64Packages.staging
    mangohud
    retroarch ppsspp dolphin-emu dosbox

    # --- mobile/android ---
    android-tools
    android-studio

    # --- low-confidence / needs decision ---
    # hactool            # VERIFY (Switch NCA tool)
    # NOT in nixpkgs (AUR-only) — flatpak or VPN config instead:
    #   surfshark-client -> wireguard/openvpn config
    #   recordly-bin     -> obs-studio or flatpak
  ];
in
{
  home.packages = base ++ lib.optionals (!osConfig.my.lean) heavy;
}
