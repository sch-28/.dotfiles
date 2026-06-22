# Real-machine profile — imported by desktop.nix + laptop.nix, NOT the VM.
# Holds the heavy / hardware-facing things the throwaway VM should not drag in
# (Steam's multi-GB FHS + Proton-GE, bluetooth/printing/scanner/SMART stacks).
{ pkgs, ... }:
{
  # --- System health check (replaces the imperative system-check.service/.timer
  #     that install.sh copied into /etc). Runs scripts/check.sh on boot + every
  #     6h, caches to /tmp/system-check.log which .zshrc shows in the first pane.
  systemd.services.system-check = {
    description = "System stability health check";
    after = [ "local-fs.target" ];
    path = with pkgs; [
      btrfs-progs util-linux smartmontools snapper
      gawk gnused gnugrep coreutils
      systemd # journalctl — without it the kernel/MCE checks silently return OK
    ];
    serviceConfig.Type = "oneshot";
    script = builtins.readFile ../../scripts/check.sh;
  };
  systemd.timers.system-check = {
    description = "Run system health check on boot and every 6 hours";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "6h";
      Persistent = true;
    };
  };

  # --- Gaming (GPU-agnostic; the driver is per-host) ---
  # programs.steam builds Steam in an FHS sandbox that auto-provides every
  # 32/64-bit lib Proton/Wine need — replaces the whole lib32-* wall.
  hardware.graphics.enable32Bit = true; # 32-bit Vulkan/OpenGL for Proton/Wine
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;

  # --- Peripherals (pointless on the VM) ---
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.printing.enable = true; # cups
  hardware.sane.enable = true; # scanners
  services.smartd.enable = true; # disk SMART (your check.sh uses smartctl)

  # --- Remote access (real machines only) ---
  services.openssh.enable = true;
  services.tailscale.enable = true;

  # --- Docker ---
  # Pin docker_29 (29.5.3): the default `docker` attr in this channel is 28.5.2,
  # which is EOL-flagged. 29 is the current non-EOL release. (jan is in the
  # "docker" group via common.nix.)
  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29;
  };
}

