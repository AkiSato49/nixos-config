{ pkgs, theme, ... }:

let
  c = theme.colors;
  wallpaper = ../../assets/wallpapers/casino-login.png;
in {
  # GTKLock gives lock screen real power controls; Hyprlock has no clickable
  # widget API. GTKLock runs through PAM as the currently locked user.
  programs.gtklock = {
    enable = true;
    modules = [ pkgs.gtklock-powerbar-module ];
    config = {
      main = {
        background = "${wallpaper}";
        "time-format" = "%H:%M";
        "date-format" = "%A · %d %B";
        "follow-focus" = true;
        "idle-hide" = false;
      };
    };
    style = ''
      window {
        background-image: url("${wallpaper}");
        background-size: cover;
        background-position: center;
      }

      #window-box {
        background: rgba(249, 245, 215, 0.76);
        border-radius: 24px;
        padding: 36px 48px;
        color: ${c.fg};
      }

      entry {
        min-height: 42px;
        border: 2px solid ${c.yellow};
        border-radius: 12px;
        background: ${c.bg_hard};
        color: ${c.fg};
      }

      #powerbar-box button {
        min-height: 36px;
        padding: 6px 12px;
        border: 1px solid rgba(60, 56, 54, 0.18);
        border-radius: 999px;
        background: rgba(251, 241, 199, 0.9);
        color: ${c.fg};
      }

      #powerbar-box button:hover {
        background: ${c.yellow};
        color: ${c.bg_hard};
      }
    '';
  };
}
