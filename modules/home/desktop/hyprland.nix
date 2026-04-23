{ config, pkgs, inputs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;

    extraConfig = ''
      monitor = ,preferred,auto,1

      $mod = SUPER

      general {
        gaps_in = 5
        gaps_out = 10
        border_size = 2
        col.active_border = rgba(d79921ff) rgba(b57614ff) 45deg
        col.inactive_border = rgba(282828ff)
        layout = dwindle
        resize_on_border = true
      }

      decoration {
        rounding = 8
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

      animations {
        enabled = true
        bezier = wind, 0.05, 0.9, 0.1, 1.05
        bezier = winIn, 0.1, 1.1, 0.1, 1.1
        bezier = winOut, 0.3, -0.3, 0, 1
        bezier = liner, 1, 1, 1, 1
        animation = windows, 1, 6, wind, slide
        animation = windowsIn, 1, 6, winIn, slide
        animation = windowsOut, 1, 5, winOut, slide
        animation = border, 1, 1, liner
        animation = fade, 1, 10, default
        animation = workspaces, 1, 5, wind
      }

      dwindle {
        pseudotile = true
        preserve_split = true
      }

      input {
        kb_layout = us
        follow_mouse = 1
        sensitivity = 0
        touchpad {
          natural_scroll = true
          tap-to-click = true
          drag_lock = true
        }
      }

      misc {
        force_default_wallpaper = 0
        disable_hyprland_logo = true
        animate_manual_resizes = true
      }

      exec-once = waybar
      exec-once = nm-applet --indicator
      exec-once = mako
      exec-once = hyprpaper
      exec-once = wl-paste --type text --watch cliphist store
      exec-once = wl-paste --type image --watch cliphist store
      exec-once = udiskie &
      exec-once = kanshi &
      exec-once = /run/current-system/sw/bin/gnome-keyring-daemon --start --components=secrets
      exec-once = 1password --silent
      exec-once = ${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent

      # Core
      bind = $mod, Return, exec, alacritty
      bind = $mod, Space, exec, wofi --show drun
      bind = $mod, Q, killactive
      bind = $mod, F, fullscreen
      bind = $mod, V, togglefloating
      bind = $mod, P, pseudo
      bind = $mod CTRL, L, exec, hyprlock
      bind = $mod, T, layoutmsg, togglesplit
      bind = $mod, B, exec, zen
      bind = $mod, E, exec, nautilus

      # Screenshots
      bind = , Print, exec, grimblast copy area
      bind = SHIFT, Print, exec, grimblast copy screen
      bind = $mod SHIFT, S, exec, grimblast save area - | swappy -f -

      # Clipboard
      bind = $mod, Y, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy

      # Focus
      bind = $mod, left,  movefocus, l
      bind = $mod, right, movefocus, r
      bind = $mod, up,    movefocus, u
      bind = $mod, down,  movefocus, d
      bind = $mod, h, movefocus, l
      bind = $mod, l, movefocus, r
      bind = $mod, k, movefocus, u
      bind = $mod, j, movefocus, d

      # Move windows
      bind = $mod SHIFT, left,  movewindow, l
      bind = $mod SHIFT, right, movewindow, r
      bind = $mod SHIFT, up,    movewindow, u
      bind = $mod SHIFT, down,  movewindow, d
      bind = $mod SHIFT, h, movewindow, l
      bind = $mod SHIFT, l, movewindow, r
      bind = $mod SHIFT, k, movewindow, u
      bind = $mod SHIFT, j, movewindow, d

      # Workspaces
      bind = $mod, 1, workspace, 1
      bind = $mod, 2, workspace, 2
      bind = $mod, 3, workspace, 3
      bind = $mod, 4, workspace, 4
      bind = $mod, 5, workspace, 5
      bind = $mod, 6, workspace, 6
      bind = $mod, 7, workspace, 7
      bind = $mod, 8, workspace, 8
      bind = $mod, 9, workspace, 9

      # Move to workspace
      bind = $mod SHIFT, 1, movetoworkspace, 1
      bind = $mod SHIFT, 2, movetoworkspace, 2
      bind = $mod SHIFT, 3, movetoworkspace, 3
      bind = $mod SHIFT, 4, movetoworkspace, 4
      bind = $mod SHIFT, 5, movetoworkspace, 5
      bind = $mod SHIFT, 6, movetoworkspace, 6
      bind = $mod SHIFT, 7, movetoworkspace, 7
      bind = $mod SHIFT, 8, movetoworkspace, 8
      bind = $mod SHIFT, 9, movetoworkspace, 9

      # Scroll workspaces
      bind = $mod, mouse_down, workspace, e+1
      bind = $mod, mouse_up, workspace, e-1

      # Audio
      bind = , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
      bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bind = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

      # Brightness
      bind = , XF86MonBrightnessUp,   exec, brightnessctl set 5%+
      bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

      # Media
      bind = , XF86AudioPlay, exec, playerctl play-pause
      bind = , XF86AudioNext, exec, playerctl next
      bind = , XF86AudioPrev, exec, playerctl prev

      bindm = $mod, mouse:272, movewindow
      bindm = $mod, mouse:273, resizewindow

      windowrule = float on, match:class pavucontrol
      windowrule = float on, match:class blueman-manager
      windowrule = float on, match:class nm-connection-editor
      windowrule = float on, match:class 1Password
      windowrule = float on, match:class swappy
      windowrule = float on, match:title Picture-in-Picture
      windowrule = pin on, match:title Picture-in-Picture
      windowrule = suppress_event maximize, match:class .*
    '';
  };
}
