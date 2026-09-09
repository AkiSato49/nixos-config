{ config, pkgs, inputs, ... }:

{
  imports = [
    ./immich-storage.nix
    ./hardware-configuration.nix
    ../../modules/nixos/profiles/desktop.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/home-utility-fetchers.nix
  ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSeBo="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  networking.hostName = "mambo";
  taildrive.shareName = "mamboh";
  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_AU.UTF-8";

  users.users.lawliet = {
    isNormalUser = true;
    description = "lawliet";
    extraGroups = [ "networkmanager" "wheel" "docker" "input" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIrozfwAKPWxBjT3E4De1uzg9umySfKuC5yRb1X/psb6"
    ];
  };

  programs.zsh.enable = true;

  # Low-latency desktop streaming host; pair from Moonlight on casino.
  services.sunshine = {
    enable = true;
    openFirewall = true;
  };
  programs.dconf.enable = true;

  # GTK portal supplements Hyprland portal registered by programs.hyprland.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    xdgOpenUsePortal = true;
    config.common.default = "*";
  };

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    vim
    playerctl
    gnome-keyring
    # Desktop-specific — no brightnessctl needed
  ];

  security.polkit.enable = true;

  system.stateVersion = "26.05";
}
