# Surface Go (1st gen) — Pentium 4415Y, 4GB RAM, 64GB eMMC. THROWAWAY TEST BOX
# for rehearsing the real-metal install before touching desktop/laptop.
# Clean wipe (no /home to preserve). Lean: `my.lean = true` drops the heavy app
# tier so it fits 64GB.
{ inputs, ... }:
{
  imports = [
    ./common.nix
    ../profiles/portable.nix # Intel iGPU + power + zram (shared with laptop)
    inputs.nixos-hardware.nixosModules.microsoft-surface-go # linux-surface kernel, wifi, touch
    # ./hardware-configuration-surface.nix  # <-- generated ON the surface, then uncomment
  ];

  networking.hostName = "surface";
  my.lean = true; # drop heavy GUI/toolchains/gaming — fits 4GB/64GB

  # NOT imported: workstation.nix — no gaming/docker/SMART on a 4GB test box.

  warnings = [
    "surface.nix uses PLACEHOLDER disk labels. Replace with the generated hardware-configuration.nix before installing."
  ];

  # === Bootloader — UEFI systemd-boot ===
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # === Placeholder disks — REPLACE with generated config on the device ===
  # Surface Go eMMC is typically /dev/mmcblk0; nixos-generate-config writes the
  # real UUIDs. This is just a shape so the flake evaluates beforehand.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };
}
