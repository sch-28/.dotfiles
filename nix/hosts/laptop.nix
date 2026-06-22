# Laptop — Intel iGPU, battery/power management.
# Shares everything in common.nix (i3, services, fonts, all apps).
# On the real install run `nixos-generate-config` on the LAPTOP and replace the
# placeholder disk block below with its generated hardware-configuration.nix.
{ inputs, ... }:
{
  imports = [
    ./common.nix
    ../profiles/workstation.nix # gaming + peripherals (real machine)
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    # ./hardware-configuration-laptop.nix   # <-- generated ON the laptop, then uncomment
  ];

  networking.hostName = "laptop";

  warnings = [
    "laptop.nix uses PLACEHOLDER disk labels (nixos/BOOT). Replace with the generated hardware-configuration.nix before installing."
  ];

  # === GPU — Intel integrated ===
  # gaming base (steam/graphics 32-bit) comes from common.nix; just the driver.
  services.xserver.videoDrivers = [ "modesetting" ];
  services.thermald.enable = true; # Intel thermal management

  # === Power management (laptop) ===
  services.power-profiles-daemon.enable = true; # balances perf/battery (upower in common)
  # Lid behaviour:
  services.logind.settings.Login.HandleLidSwitch = "suspend";

  # Backlight control for the laptop panel:
  programs.light.enable = true;

  # === Bootloader — assume UEFI systemd-boot on the laptop ===
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # === Placeholder disks — REPLACE with the laptop's generated config ===
  # nixos-generate-config writes the real device UUIDs; this is just a shape so
  # the flake evaluates before you have that machine's hardware file.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };
}
