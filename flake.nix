{
  description = "jan dotfiles — NixOS + home-manager (reuses existing stow configs)";

  inputs = {
    # Bump channel when you want newer pkgs. 25.11 = known-good stable.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
      };
    };
}
