{
  description = "lawliet's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, zen-browser, ... } @ inputs:
  let
    system = "x86_64-linux";
    pkgs   = nixpkgs.legacyPackages.${system};
    theme  = import ./modules/themes/default.nix;
  in {
    nixosConfigurations = {
      # Laptop
      NixOS = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs theme; };
        modules = [
          ./hosts/nixos/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs      = true;
            home-manager.useUserPackages    = true;
            home-manager.users.lawliet      = import ./home/lawliet.nix;
            home-manager.extraSpecialArgs   = { inherit inputs theme; };
          }
        ];
      };

      # Desktop (Ryzen 5 5600X + RTX 3070 Ti)
      desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs theme; };
        modules = [
          ./hosts/desktop/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs      = true;
            home-manager.useUserPackages    = true;
            home-manager.users.lawliet      = import ./home/lawliet.nix;
            home-manager.extraSpecialArgs   = { inherit inputs theme; };
          }
        ];
      };
    };
  };
}
