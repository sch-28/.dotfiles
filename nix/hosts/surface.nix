# Surface Go (1st gen) — Pentium 4415Y, 4GB RAM, 64GB eMMC. THROWAWAY TEST BOX
# for rehearsing the real-metal install before touching desktop/laptop.
# Clean wipe (no /home to preserve). Lean: `my.lean = true` drops the heavy app
# tier so it fits 64GB.
{ inputs, ... }:
{
  imports = [
    ./common.nix
    ../profiles/portable.nix # Intel iGPU + power + zram (shared with laptop)
    ./hardware-configuration-surface.nix # real UUIDs + eMMC initrd modules
    # microsoft-surface-go pulls the linux-surface kernel, which is BUILT FROM
    # SOURCE (no binary cache) — a ~2h compile on this 4GB Pentium. Disabled so
    # the install uses the cached mainline kernel (minutes). Re-enable later when
    # you want touch/pen and can spare the one-time compile.
    # inputs.nixos-hardware.nixosModules.microsoft-surface-go
  ];

  networking.hostName = "surface";
  my.lean = true; # drop heavy GUI/toolchains/gaming — fits 4GB/64GB

  # NOT imported: workstation.nix — no gaming/docker/SMART on a 4GB test box.

  # === Bootloader — UEFI systemd-boot ===
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10; # cap generations — 512MB ESP

  # Disks come from hardware-configuration-surface.nix (generated on the device).

  # Disk swapfile as a slow second tier behind zram (priority 5 from
  # zram-generator). 4 GB on the 64 GB eMMC — kicks in only when zram is full,
  # so it absorbs the next memory spike without thrash-livelocking the GUI.
  # Slow > frozen. NixOS creates the file on first activation.
  swapDevices = [{
    device = "/swapfile";
    size = 4096; # MB
    priority = 1; # lower than zram (5) → kernel prefers zram
  }];
}
