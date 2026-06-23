# Laptop — Intel iGPU, battery/power management.
# Shares everything in common.nix (i3, services, fonts, all apps).
# On the real install run `nixos-generate-config` on the LAPTOP and replace the
# placeholder disk block below with its generated hardware-configuration.nix.
{ inputs, ... }:
{
  imports = [
    ./common.nix
    ../profiles/workstation.nix # gaming + peripherals (real machine)
    ../profiles/portable.nix # Intel iGPU + power + zram (shared with surface)
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    # ./hardware-configuration-laptop.nix   # <-- generated ON the laptop, then uncomment
  ];

  networking.hostName = "laptop";

  warnings = [
    "laptop.nix uses PLACEHOLDER disk labels (nixos/BOOT). Replace with the generated hardware-configuration.nix before installing."
  ];

  # GPU + power + zram come from profiles/portable.nix.

  # === Bootloader — assume UEFI systemd-boot on the laptop ===
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10; # cap generations on the ESP

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
