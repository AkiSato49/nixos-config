{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/profiles/desktop.nix
    ../../modules/nixos/power.nix
    ../../modules/nixos/obs.nix
    ../../modules/nixos/photography.nix
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
        "https://noctalia.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSeBo="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  networking.hostName = "casino";
  taildrive.shareName = "casinoh";
  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_AU.UTF-8";

  users.users.lawliet = {
    isNormalUser = true;
    description = "lawliet";
    extraGroups = [ "networkmanager" "wheel" "docker" "input" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.dconf.enable = true;
  programs.steam.enable = true;

  # Laptop, Thunderbolt dock, and peripheral firmware updates through LVFS.
  services.fwupd.enable = true;

  # Authorize enrolled Thunderbolt devices on hotplug. Without Bolt, dock USB
  # works but its DisplayPort tunnel stays blocked until a reboot.
  services.hardware.bolt.enable = true;

  # GTK portal supplements Hyprland portal registered by programs.hyprland
  xdg.portal = {
    enable = true;
    # programs.hyprland supplies xdg-desktop-portal-hyprland.
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    xdgOpenUsePortal = false;
    config.common.default = "*";
  };

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    vim
    brightnessctl
    playerctl
    gnome-keyring
    networkmanagerapplet

    # Browser test runner plus NixOS-patched Chromium, Firefox, and WebKit.
    playwright-test
    playwright-driver.browsers
  ];

  environment.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
  };

  # Polkit agent
  security.polkit.enable = true;

  system.stateVersion = "26.05";
}
