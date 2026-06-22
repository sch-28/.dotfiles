{
  description = "jan dotfiles — NixOS + home-manager (reuses existing stow configs)";

  inputs = {
    # 26.05 = current stable (verified live, not assumed). Bump when a newer
    # stable releases (e.g. 26.11 in Nov 2026).
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Per-machine hardware tuning (CPU microcode, GPU, SSD, laptop defaults).
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs =
    { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";

      # One builder for every host. Add a host = mkHost "name" line below
      # and drop a nix/hosts/<name>.nix file. That is the whole extension story.
      mkHost =
        host:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs self; };
          modules = [
            ./nix/hosts/${host}.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs self; };
              home-manager.users.jan = import ./nix/home;
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        vm = mkHost "vm"; # throwaway test target — nixos-rebuild build-vm
        desktop = mkHost "desktop"; # 7800X3D + RTX 4090, keeps /home on p7
        laptop = mkHost "laptop"; # Intel iGPU, battery/power mgmt
        surface = mkHost "surface"; # Surface Go test box — lean, clean wipe
      };
    };
}
