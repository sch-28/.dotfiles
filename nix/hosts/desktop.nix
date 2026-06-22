# Real metal. Keeps your existing /home (p7) untouched.
# On the real install run `nixos-generate-config` and replace the
# placeholder hardware block + mounts below with the generated file.
{ config, inputs, ... }:
{
  imports = [
    ./common.nix
    ../profiles/workstation.nix # gaming + peripherals (real machine)
    # nixos-hardware tuning for this box (microcode, kernel params, SSD).
    # NOTE: common-gpu-nvidia is intentionally NOT imported — it assumes a
    # hybrid laptop and enables PRIME (needs bus IDs). This is a desktop with
    # monitors on the 4090, so the manual hardware.nvidia block below is correct.
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    # ./hardware-configuration.nix   # <-- generated on real install, then uncomment
  ];

  networking.hostName = "desktop";

  # !!! PLACEHOLDER DISKS — see fileSystems below. Replace with
  # nixos-generate-config (UUID-based) BEFORE `nixos-install`. Printed each build:
  warnings = [
    "desktop.nix uses PLACEHOLDER disk devices (/dev/nvme0n1pN). Replace with the generated hardware-configuration.nix before installing, or you risk mounting the wrong partition."
  ];

  # === GPU — NVIDIA RTX 4090 (Ada; open module is recommended) ===
  # gaming base (steam/graphics 32-bit) is in common.nix — only the driver here.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true; # nvidia-open kernel module (your nvidia-open-lts)
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Bootloader -> reuse existing ESP at /efi (do NOT reformat it — it holds the
  # Windows boot entry). canTouchEfiVariables=true so systemd-boot registers its
  # NVRAM entry on first install (default is false). Adds a "Linux Boot Manager"
  # entry alongside Windows; does not remove the Windows one.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.efiSysMountPoint = "/efi";
  boot.loader.efi.canTouchEfiVariables = true;

  # === EXISTING partitions — formatted ONLY p6 (root) on install ===
  # p7 = /home (@home subvol) -> keep your 1.3T of data.
  fileSystems."/home" = {
    device = "/dev/nvme0n1p7";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd:3" "noatime" ];
  };
  fileSystems."/efi" = {
    device = "/dev/nvme0n1p8";
    fsType = "vfat";
  };
  swapDevices = [ { device = "/dev/nvme0n1p4"; } ];

  # root (p6) — generate real config; this is a placeholder shape.
  fileSystems."/" = {
    device = "/dev/nvme0n1p6";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd:3" "noatime" ];
  };
}
