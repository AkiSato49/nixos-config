{ config, pkgs, inputs, ... }:

{
  imports = [
    ../modules/home/desktop/hyprland.nix
    ../modules/home/desktop/hyprpaper.nix
    ../modules/home/desktop/hyprlock.nix
    ../modules/home/desktop/waybar.nix
    ../modules/home/desktop/mako.nix
    ../modules/home/desktop/wofi.nix
    ../modules/home/desktop/theming.nix
    ../modules/home/desktop/kanshi.nix
    ../modules/home/shell/zsh.nix
    ../modules/home/shell/tools.nix
    ../modules/home/apps/alacritty.nix
    ../modules/home/apps/neovim.nix
    ../modules/home/apps/media.nix
    ../modules/home/dev/default.nix
  ];

  home = {
    username = "lawliet";
    homeDirectory = "/home/lawliet";
    stateVersion = "26.05";

    packages = with pkgs; [
      # Browser (zen via flake — see hyprland.nix for the package ref)
      inputs.zen-browser.packages.${pkgs.system}.default

      # Office
      libreoffice-qt6-fresh

      # File manager
      nautilus

      # System utils
      btop
      ncdu
      udiskie
      smartmontools
      wlr-randr
      nmap

      # Archive tools
      unzip
      p7zip
      unrar

      # Network
      wget
      curl

      # Clipboard
      wl-clipboard
      cliphist

      # Screenshot
      grimblast
      swappy

      # Photo workflow
      darktable
      gimp
      imagemagick
      gphoto2
      digikam
      exiftool

      # Media
      mpv
      imv
      zathura

      # Communication
      vesktop

      # Notes
      obsidian

      # Misc
      yt-dlp
      ffmpeg
      qbittorrent
      translate-shell

      # Audio control
      pavucontrol

      # Brightness / media keys
      brightnessctl
      playerctl
    ];
  };

  programs.home-manager.enable = true;

  # Udiskie auto-mount
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
  };

  # XDG defaults
  xdg = {
    enable = true;
    # Ensure zsh history dir exists
    dataFile."zsh/.keep".text = "";
    userDirs = {
      enable = true;
      createDirectories = true;
      pictures = "${config.home.homeDirectory}/Pictures";
      videos   = "${config.home.homeDirectory}/Videos";
      music    = "${config.home.homeDirectory}/Music";
      download = "${config.home.homeDirectory}/Downloads";
      documents = "${config.home.homeDirectory}/Documents";
    };
  };
}
