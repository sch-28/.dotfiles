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
  zramSwap.enable = true;
}
