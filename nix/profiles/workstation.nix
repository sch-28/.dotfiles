# Real-machine profile — imported by desktop.nix + laptop.nix, NOT the VM.
# Holds the heavy / hardware-facing things the throwaway VM should not drag in
# (Steam's multi-GB FHS + Proton-GE, bluetooth/printing/scanner/SMART stacks).
{ pkgs, ... }:
{
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

