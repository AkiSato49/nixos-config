{ config, pkgs, inputs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;

    extraConfig = ''
      decoration {
        blur {
          enabled = true
          size = 3
          passes = 2
        }
        shadow {
          enabled = true
          range = 8
          render_power = 3
          color = rgba(1a1a1aee)
        }
      }

      windowrule = float, class:^(pavucontrol)$
      windowrule = float, class:^(blueman-manager)$
      windowrule = float, class:^(nm-connection-editor)$
      windowrule = float, class:^(1Password)$
      windowrule = float, class:^(swappy)$
      windowrule = float, title:^(Picture-in-Picture)$
      windowrule = pin, title:^(Picture-in-Picture)$
      windowrule = suppressevent maximize, class:.*
    '';

    settings = {
      monitor = [
        # Default — all monitors auto-detected
        # Add specific monitor rules here after running `hyprctl monitors`
        # Example: "DP-1,2560x1440@144,0x0,1"
        ",preferred,auto,1"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border"   = "rgba(d79921ff) rgba(b57614ff) 45deg";
        "col.inactive_border" = "rgba(282828ff)";
        layout = "dwindle";
        resize_on_border = true;
      };

      decoration = {
        rounding = 8;
      };

      animations = {
        enabled = true;
        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
        ];
        animation = [
          "windows, 1, 6, wind, slide"
          "windowsIn, 1, 6, winIn, slide"
          "windowsOut, 1, 5, winOut, slide"
          "border, 1, 1, liner"
          "fade, 1, 10, default"
          "workspaces, 1, 5, wind"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          drag_lock = true;
        };
      };

      # gestures removed in Hyprland 0.46+ (touchpad swipe via libinput now)

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        animate_manual_resizes = true;
      };

      exec-once = [
        "waybar"
        "mako"
        "hyprpaper"
        # cliphist: store text + images separately
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "udiskie &"
        "kanshi &"
        "/run/current-system/sw/bin/gnome-keyring-daemon --start --components=secrets"
        "1password --silent"
        "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent"
      ];

      "$mod" = "SUPER";

      bind = [
        # Core
        "$mod, Return, exec, alacritty"
        "$mod, Space, exec, wofi --show drun"
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        "$mod, V, togglefloating"
        "$mod, P, pseudo"
        # NOTE: $mod,L and $mod,J are used for vim focus — hyprlock on CTRL+SUPER+L
        "$mod CTRL, L, exec, hyprlock"
        "$mod, T, layoutmsg, togglesplit"
        "$mod, B, exec, zen"
        "$mod, E, exec, nautilus"

        # Screenshots (grimblast + swappy)
        ", Print, exec, grimblast copy area"
        "SHIFT, Print, exec, grimblast copy screen"
        "$mod SHIFT, S, exec, grimblast save area - | swappy -f -"

        # Clipboard history
        "$mod, Y, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

        # Focus (vim keys + arrows)
        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        # Move windows
        "$mod SHIFT, left,  movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up,    movewindow, u"
        "$mod SHIFT, down,  movewindow, d"
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, l, movewindow, r"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, j, movewindow, d"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # Move to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"

        # Scroll through workspaces
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # Audio
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

        # Brightness
        ", XF86MonBrightnessUp,   exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"

        # Media
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl prev"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

    };
  };
}
