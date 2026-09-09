{ config, pkgs, inputs, lib, hostName, ... }:

{
  imports = [
    ../modules/home/desktop/hyprland.nix
    ../modules/home/desktop/hyprpaper.nix
    ../modules/home/desktop/hyprlock.nix
    ../modules/home/desktop/noctalia.nix
    ../modules/home/desktop/theming.nix
    ../modules/home/desktop/kanshi.nix
    ../modules/home/shell/zsh.nix
    ../modules/home/shell/tools.nix
    ../modules/home/apps/alacritty.nix
    ../modules/home/apps/helium.nix
    ../modules/home/apps/neovim.nix
    ../modules/home/apps/media.nix
    ../modules/home/apps/whisper.nix
    ../modules/home/apps/dictation.nix
    ../modules/home/dev/default.nix
    ../modules/home/dev/pi.nix
  ];

  home = {
    username = "lawliet";
    homeDirectory = "/home/lawliet";
    stateVersion = "26.05";

    packages = with pkgs; (lib.optionals (hostName == "mambo") [
      # Resolve needs Mambo's RTX 3070 Ti; casino's Intel iGPU is unsupported.
      davinci-resolve
    ]) ++ [
      # Browser (zen via flake — see hyprland.nix for the package ref)
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

      # Office
      libreoffice-qt6-fresh
      pdfarranger

      # Design
      figma-linux

      # File manager
      nautilus

      # System utils
      btop
      ncdu
      udiskie
      smartmontools
      usbutils
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
      inkscape
      krita
      (import inputs.blender-nixpkgs {
        system = pkgs.stdenv.hostPlatform.system;
      }).blender

      # Media
      spotify
      mpv
      imv
      zathura

      # Communication
      vesktop
      localsend

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

  # Let HM take over files that may already exist (e.g. from a previous manual setup).
  # Removes plain files (not symlinks) in all dirs HM manages — runs before link-check.
  home.activation.clearConflicts = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    # Dirs fully managed by HM modules — wipe plain files, leave symlinks alone
    for dir in hypr ghostty nvim lazygit gtk-3.0 gtk-4.0 waybar mako wofi; do
      if [ -d "$HOME/.config/$dir" ]; then
        find "$HOME/.config/$dir" -maxdepth 3 -type f ! -type l -delete 2>/dev/null || true
      fi
    done
    # Phase 1 replaces Phase 0's managed shell.qml file with one managed QS directory.
    rm -rf "$HOME/.config/quickshell/lawliet-shell"
    # Standalone dotfiles
    rm -f \
      $HOME/.config/mimeapps.list \
      $HOME/.config/user-dirs.dirs \
      $HOME/.gtkrc-2.0
  '';

  # Udiskie auto-mount
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
  };

  # XDG defaults
  xdg = {
    enable = true;
    # Ensure zsh history dir exists
    dataFile."zsh/.keep".text = "";
    configFile."swappy/config".text = ''
      [Default]
      save_dir=${config.home.homeDirectory}/Pictures/Screenshots
      save_filename_format=screenshot_%Y%m%d_%H%M%S.png
    '';
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
