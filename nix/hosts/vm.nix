# Throwaway VM target. Self-contained, no real disks.
# Build + run:  nixos-rebuild build-vm --flake .#vm
#               ./result/bin/run-vm-vm
{ ... }:
{
  imports = [ ./common.nix ];

  networking.hostName = "vm";

  # Passwords are NOT carried from your host. Set a known one to log in.
  users.users.jan.initialPassword = "nix";

  # Give the VM enough to run i3 comfortably (default 1 CPU / 1G is too small).
  virtualisation.vmVariant.virtualisation = {
    cores = 4;
    memorySize = 4096; # MiB
    diskSize = 8192;
    # gl=off: host GTK backend here has no working EGL/OpenGL. virtio vga still
    # gives a fine 2D framebuffer for i3/polybar. Flip to gl=on if your host GL works.
    qemu.options = [ "-vga virtio" "-display gtk,gl=off" ];
  };

  # Minimal bootloader. build-vm synthesizes its own root disk (virtio /dev/vda)
  # and direct-kernel-boots, but the toplevel system must still evaluate a valid
  # bootloader + root fs. grub-on-nodev + /dev/vda evaluates cleanly; build-vm
  # overrides the root mount at runtime. (systemd-boot would assert on a missing
  # ESP here.)
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };
}
