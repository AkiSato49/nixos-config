{ config, inputs, lib, ... }:

{
  imports = [ inputs.noctalia.homeModules.default ];

  # Noctalia owns bar, panels, launcher, notifications, OSD, and session menu.
  # GTKLock remains recovery lock until Noctalia lock hardware tests pass.
  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    settings = {
      theme = {
        mode = "light";
        source = "builtin";
        builtin = "Noctalia";
      };
      wallpaper.enabled = false;
      lockscreen = {
        enabled = true;
        fingerprint = true;
        # Let Enter on an empty password field invoke PAM fingerprint auth.
        # Noctalia otherwise rejects empty submissions before PAM runs.
        allow_empty_password = true;
        lock_before_suspend = true;
        # `set-wallpaper` regenerates this file before applying Hyprpaper.
        # Use same image on lock surface without exposing desktop windows.
        wallpaper = "${config.home.homeDirectory}/Pictures/wallpapers/edp1.png";
        blurred_desktop = false;
      };

      plugins = {
        enabled = [ "lawliet/mobile-data" ];
        source = [
          {
            name = "lawliet-mobile-data";
            kind = "path";
            location = "${config.xdg.configHome}/noctalia/plugins";
            enabled = true;
          }
        ];
      };

      bar.default.end = [
        "media"
        "tray"
        "notifications"
        "clipboard"
        "network"
        "mobile-data"
        "bluetooth"
        "volume"
        "brightness"
        "battery"
        "control-center"
        "session"
      ];
      widget."mobile-data".type = "lawliet/mobile-data:mobile-data";


    };
  };

  home.file = {
    ".config/noctalia/plugins/lawliet-mobile-data/plugin.toml".source = ./noctalia-mobile-data/plugin.toml;
    ".config/noctalia/plugins/lawliet-mobile-data/widget.luau".source = ./noctalia-mobile-data/widget.luau;
    ".config/noctalia/plugins/lawliet-mobile-data/panel.luau".source = ./noctalia-mobile-data/panel.luau;
  };

  # Removed Home Manager units do not stop an already-running service.
  home.activation.stopQuickshell = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD systemctl --user disable --now quickshell-lawliet.service 2>/dev/null || true
  '';
}
