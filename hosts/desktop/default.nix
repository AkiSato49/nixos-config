{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/flatpak.nix
    ../../modules/nixos/security.nix
    ../../modules/nixos/greetd.nix
    ../../modules/nixos/tailscale.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/openclaw.nix
    # power.nix intentionally excluded (desktop, no battery)
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

  networking.hostName = "desktop";
  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_AU.UTF-8";

  users.users.lawliet = {
    isNormalUser = true;
    description = "lawliet";
    extraGroups = [ "networkmanager" "wheel" "docker" "audio" "video" "input" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.dconf.enable = true;

  # XDG portals for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
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
  ] ++ [ pkgs.lxqt.lxqt-policykit ];

  security.polkit.enable = true;

  system.stateVersion = "26.05";
}
