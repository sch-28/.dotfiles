# Shared system config — imported by every host. System-level only;
# user/app config lives in nix/home/. GPU drivers + disks are per-host.
{ pkgs, ... }:
{
  imports = [ ../modules/lean.nix ]; # defines the `my.lean` flag (used by home)

  # Flakes + new CLI.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true; # slack, spotify, nvidia, steam...
  # bitwarden-desktop 2026.2.1 pins electron_39, which upstream flags EOL.
  # Whitelisted so the desktop app builds — it ships its own local UI (not a web
  # browser), so the EOL-electron risk is limited. Revisit when a newer bitwarden
  # bumps electron. (To avoid entirely: use the browser extension / web vault.)
  nixpkgs.config.permittedInsecurePackages = [ "electron-39.8.10" ];

  # ============================================================
  #  Desktop: X11 + i3 + ly
  # ============================================================
  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
    xkb.layout = "de"; # kmonad remaps on metal; "de" is the base layout
  };
  console.keyMap = "de";
  services.displayManager.ly.enable = true;
  services.libinput.enable = true; # touchpad / mouse (gestures dotfile)
  programs.dconf.enable = true; # gtk app settings

  # ============================================================
  #  Audio — pipewire (you use pw-play + pulse)
  # ============================================================
  security.rtkit.enable = true; # realtime priority for pipewire
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  };

  # ============================================================
  #  Networking
  # ============================================================
  networking.networkmanager.enable = true;
  networking.firewall.enable = true; # NixOS default; replaces firewalld
  services.avahi = {
    enable = true;
    nssmdns4 = true; # .local mDNS resolution (was nss-mdns)
  };
  # NOTE: bluetooth, printing, scanner, SMART, ssh, tailscale, and the gaming
  # stack live in profiles/workstation.nix (imported by desktop+laptop, not the
  # VM) so the throwaway VM doesn't drag in Steam's multi-GB closure etc.

  services.upower.enable = true; # battery / power state

  # ============================================================
  #  Files / thumbnails / search
  # ============================================================
  services.gvfs.enable = true; # thunar/nemo mounting (mtp, smb, trash)
  services.tumbler.enable = true; # thumbnails in file managers
  services.locate = {
    enable = true;
    package = pkgs.plocate;
  };

  # ============================================================
  #  Security / secrets
  # ============================================================
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true; # you autostart it in i3
  security.pam.services.ly.enableGnomeKeyring = true; # unlock on login
  programs.seahorse.enable = true; # keyring GUI

  # ============================================================
  #  Integrations
  # ============================================================
  programs.kdeconnect.enable = true;

  # Base graphics (any GPU). 32-bit + the gaming stack are in
  # profiles/workstation.nix so the VM stays lean.
  hardware.graphics.enable = true;

  # ============================================================
  #  Fonts
  # ============================================================
  fonts = {
    enableDefaultPackages = true;
    fontconfig.enable = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      dejavu_fonts
      liberation_ttf
      open-sans
      cantarell-fonts
      font-awesome # polybar glyphs (was awesome-terminal-fonts)
      nerd-fonts.jetbrains-mono # terminal/bar icon glyphs
    ];
  };

  # ============================================================
  #  User — uid 1000 matches existing /home/jan ownership
  # ============================================================
  # uid 1000 + primary group `jan` gid 1000 — MUST match the existing
  # /home/jan ownership (Arch uses a per-user group), else 1.3TB gets wrong
  # group perms. NixOS would otherwise default the primary group to users(100).
  users.groups.jan.gid = 1000;
  users.users.jan = {
    isNormalUser = true;
    uid = 1000;
    group = "jan";
    extraGroups = [ "wheel" "networkmanager" "docker" "video" "audio" "input" "scanner" "lp" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # ============================================================
  #  System packages — MINIMAL. Software lives in nix/home/packages.nix;
  #  this is the rescue/root set available without logging in as jan.
  # ============================================================
  environment.systemPackages = with pkgs; [
    git vim wget curl
    pciutils usbutils # lspci / lsusb for diagnosis
  ];

  system.stateVersion = "26.05"; # do NOT change after install
}
