# Defines the `my.lean` flag. A lean host (low RAM/disk, e.g. the 4GB/64GB
# Surface Go) sets `my.lean = true` and home-manager drops the heavy app tier
# (see nix/home/modules/packages.nix, which reads osConfig.my.lean).
{ lib, ... }:
{
  options.my.lean = lib.mkEnableOption
    "lean host (low RAM/disk): skip the heavy GUI app + toolchain tier";
}
