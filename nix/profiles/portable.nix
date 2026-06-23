# Portable profile — Intel-iGPU, battery-powered class. Imported by laptop +
# surface so their shared laptop/tablet config lives in ONE place.
{ ... }:
{
  # Intel integrated graphics.
  services.xserver.videoDrivers = [ "modesetting" ];
  services.thermald.enable = true; # Intel thermal management

  # Power management.
  services.power-profiles-daemon.enable = true; # balances perf/battery
  services.logind.settings.Login.HandleLidSwitch = "suspend";
  # Backlight via brightnessctl (in base packages) — programs.light was removed
  # from nixpkgs in 26.05. brightnessctl needs the user in the "video" group
  # (jan already is, see common.nix).

  # Compressed RAM swap — meaningful headroom on low-memory machines.
  # memoryPercent=100 (default 50): zstd compresses ~4× on typical workloads, so
  # 100% of RAM as zram backing costs ~25% of RAM in real footprint while
  # doubling effective working set. Critical on the 4GB Surface.
  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  # Userspace OOM killer that fires BEFORE the kernel thrash-loops itself into
  # a livelock. Default trigger: free RAM+swap below 10%/5% → kill biggest RSS.
  # On low-RAM hosts this is the difference between a dropped tab and a hard
  # power-cycle.
  services.earlyoom.enable = true;

  boot.kernel.sysctl = {
    # zram is RAM, not disk — swap to it aggressively. NixOS default 60 is
    # tuned for spinning rust; 180 is the conventional value for zram-first
    # setups.
    "vm.swappiness" = 180;
    # Enable all Magic SysRq keys. Escape hatch from a frozen GUI:
    #   Alt+SysRq+f  → force OOM kill
    #   Alt+SysRq+r,e,i,s,u,b ("REISUB") → clean reboot
    "kernel.sysrq" = 1;
  };
}
