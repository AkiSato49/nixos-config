{
  description = "lawliet's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Separate pin keeps Blender current without forcing whole system onto newer nixpkgs.
    blender-nixpkgs.url = "github:nixos/nixpkgs/b7c2ada94fe99c15b0dbcf4d11fd7850b957a436";

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

    # Pin latest Noctalia commit already built by upstream Cachix.
    # Do not follow this flake's nixpkgs: that changes its derivation hash and misses cache.
    noctalia.url = "github:noctalia-dev/noctalia/cachix";

    # Separate native greetd UI for pre-session login. Replaces ReGreet + Cage.
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, zen-browser, ... } @ inputs:
  let
    system = "x86_64-linux";
    theme  = import ./modules/themes/default.nix;

    # waybar 0.15.0 crashes in hyprland/window (segfault + mutex bug).
    # Override with git HEAD which includes both fixes:
    #   b1a87f94 fix(hyprland/window): avoid stale state during IPC refresh
    #   83e1949d fix(hyprland/window): Fix segfault caused by use-after-free
    waybarOverlay = final: prev: {
      waybar = prev.waybar.overrideAttrs (old: {
        version = "0.15.0-unstable-2026-05-03";
        src = prev.fetchFromGitHub {
          owner = "Alexays";
          repo  = "Waybar";
          rev   = "4c105f7cd7a5d8db077bdd26f1b25b3d993d9402";
          hash  = "sha256-xlNiNx9wsYdlJUTo30F6DWgKIG3Is8PzLYVRcW+Fg4w=";
        };
        # git HEAD uses cava-0.10.7 (no -beta); nixpkgs postUnpack copies -beta
        postUnpack = let
          cavaSrc = prev.fetchFromGitHub {
            owner = "LukashonakV";
            repo  = "cava";
            tag   = "0.10.7";
            hash  = "sha256-zkyj1vBzHtoypX4Bxdh1Vmwh967DKKxN751v79hzmgQ=";
          };
        in ''
          pushd "$sourceRoot"
          cp -R --no-preserve=mode,ownership ${cavaSrc} subprojects/cava-0.10.7
          patchShebangs .
          popd
        '';
        doInstallCheck = false;
      });
    };

    pkgs   = import nixpkgs { inherit system; overlays = [ waybarOverlay ]; };
    mkHost = hostName: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs theme hostName; };
      modules = [
        { nixpkgs.overlays = [ waybarOverlay ]; }
        ./hosts/${hostName}/default.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs      = true;
          home-manager.useUserPackages    = true;
          home-manager.users.lawliet      = import ./home/lawliet.nix;
          home-manager.extraSpecialArgs   = { inherit inputs theme hostName; };
        }
      ];
    };
  in {
    nixosConfigurations = {
      casino = mkHost "casino";  # Laptop
      mambo  = mkHost "mambo";   # Desktop (Ryzen 5 5600X + RTX 3070 Ti)
    };
  };
}
