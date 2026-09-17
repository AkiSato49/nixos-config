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
        # Single lock owner = hypridle (hyprlock.nix). Noctalia must not
        # race it with its own suspend lock; hypridle lock_cmd drives IPC.
        lock_before_suspend = false;
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

  # DPMS wake makes dock outputs flap while kanshi converges. Noctalia can
  # either fail on a stale wl_output (exit 1) or treat a Wayland broken pipe
  # as clean shutdown (exit 0). `on-failure` misses latter and leaves shell
  # dead, so restart after either exit. Explicit systemd stop still suppresses
  # restart. Larger burst covers pair -> triple output churn.
  systemd.user.services.noctalia = {
    Service = {
      Restart = lib.mkForce "always";
      RestartSec = "2s";
    };
    Unit.StartLimitBurst = 10;
  };
}
