{ config, pkgs, inputs, theme, hostName ? "", ... }:
let
  c = theme.colors;
  g = theme.geometry;

  # HiDPI laptop only
  big       = hostName == "casino";
  edpScale  = if big then "1.5" else "2";
  gdkScale  = if big then "1.25" else "1";
  curSize   = if big then 28 else 24;

  # Per-host monitor pinning. casino has a fixed three-display layout;
  # mambo just auto-arranges whatever's plugged in via the catch-all rule.
  monitorConfig =
    if big then ''
      # Layout (left -> right), all positions in *logical* pixels:
      #   eDP-1    : 2880x1800 / scale 1.5 -> 1920x1200 logical, at 0,0
      #   HDMI-A-1 : 2560x1440 / scale 1   -> 2560x1440 logical, at 1920,0
      #   DVI-I-1  : 2560x1440 / scale 1, rotated 270 -> 1440x2560 logical, at 4480,0
      monitor = eDP-1,    2880x1800@60, 0x0,    ${edpScale}
      monitor = HDMI-A-1, 2560x1440@60, 1920x0, 1
      monitor = DVI-I-1,  2560x1440@60, 4480x0, 1, transform, 3
    '' else "";

  # Distribute 10 workspaces across whatever monitors are connected.
  # 1 mon -> 10 ; 2 mons -> 5/5 ; 3 mons -> 4/3/3 ; etc.
  # Distribute TOTAL workspaces across all currently-connected monitors,
  # left-to-right by physical X position. Splits as evenly as possible
  # (extras go to the leftmost monitors, e.g. 10/3 -> 4,3,3). Each monitor
  # gets its first workspace marked default so focusing the monitor lands
  # on a sane workspace. Existing workspaces (with windows) are migrated
  # via moveworkspacetomonitor so nothing gets orphaned when monitors come
  # and go.
  assignWs = pkgs.writeShellScriptBin "assign-ws" ''
    set -e
    HYPRCTL=${pkgs.hyprland}/bin/hyprctl
    JQ=${pkgs.jq}/bin/jq

    # Monitors sorted left-to-right by x coordinate.
    mapfile -t mons < <($HYPRCTL monitors -j | $JQ -r 'sort_by(.x) | .[].name')
    n=''${#mons[@]}
    if [ "$n" -eq 0 ]; then
      echo "assign-ws: no monitors connected" >&2
      exit 0
    fi

    total=10
    base=$(( total / n ))
    extra=$(( total - base * n ))

    ws=1
    for i in "''${!mons[@]}"; do
      mon="''${mons[$i]}"
      count=$base
      [ "$i" -lt "$extra" ] && count=$(( count + 1 ))
      for j in $(seq 1 "$count"); do
        default=""
        [ "$j" -eq 1 ] && default=",default:true"
        # Persist the binding (survives monitor hotplug).
        $HYPRCTL keyword workspace "$ws,monitor:$mon$default" >/dev/null
        # Migrate any existing windows on this workspace to the new monitor.
        $HYPRCTL dispatch moveworkspacetomonitor "$ws $mon" >/dev/null 2>&1 || true
        ws=$(( ws + 1 ))
      done
    done

    echo "assign-ws: $total workspaces across $n monitor(s): ''${mons[*]}" >&2
    ${pkgs.procps}/bin/pkill -SIGUSR2 waybar 2>/dev/null || true
  '';

  wsListener = pkgs.writeShellScriptBin "ws-monitor-listener" ''
    SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:"$SOCK" | while IFS= read -r line; do
      case "$line" in
        monitoradded*|monitorremoved*) ${assignWs}/bin/assign-ws ;;
      esac
    done
  '';
in {
  wayland.windowManager.hyprland = {
    enable  = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

    extraConfig = ''
      ${monitorConfig}
      # Catch-all: any monitor not pinned above gets auto-placed at preferred mode.
      # On casino this only kicks in for unexpected outputs; on mambo it does
      # all the work (every connected display is auto-arranged left-to-right).
      monitor = ,preferred,auto,1

      # Workspace → monitor assignments are computed dynamically by
      # assign-ws based on currently connected monitors (1=10, 2=5/5, 3≈3/3/3, …)

      # HiDPI / scaling env — rely on per-monitor Wayland scaling.
      # GDK_SCALE removed: was making zen huge on non-HiDPI externals.
      env = GDK_DPI_SCALE,1
      env = QT_AUTO_SCREEN_SCALE_FACTOR,1
      env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
      env = MOZ_ENABLE_WAYLAND,1
      env = MOZ_USE_XINPUT2,1
      env = XCURSOR_SIZE,${toString curSize}

      $mod = SUPER

      general {
        gaps_in  = ${toString g.gaps_in}
        gaps_out = ${toString g.gaps_out}
        border_size = ${toString g.border_size}
        col.active_border   = ${theme.borders.active}
        col.inactive_border = ${theme.borders.inactive}
        layout = dwindle
        resize_on_border = true
      }

      decoration {
        rounding = ${toString g.rounding}
        blur {
          enabled = ${if g.blur then "true" else "false"}
          size    = ${toString g.blur_size}
          passes  = ${toString g.blur_passes}
        }
        shadow {
          enabled      = ${if g.shadows then "true" else "false"}
          range        = 8
          render_power = 3
          color        = rgba(1a1a1aee)
        }
      }

      animations {
        enabled = true
        bezier = wind,   0.05, 0.9,  0.1, 1.05
        bezier = winIn,  0.1,  1.1,  0.1, 1.1
        bezier = winOut, 0.3,  -0.3, 0,   1
        bezier = liner,  1,    1,    1,   1
        animation = windows,     1, 6, wind,   slide
        animation = windowsIn,   1, 6, winIn,  slide
        animation = windowsOut,  1, 5, winOut, slide
        animation = border,      1, 1, liner
        animation = fade,        1, 10, default
        animation = workspaces,  1, 5, wind
      }

      dwindle {
        pseudotile     = true
        preserve_split = true
      }

      input {
        kb_layout = us
        follow_mouse = 1
        sensitivity  = 0
        touchpad {
          natural_scroll = true
          tap-to-click   = true
          drag_lock      = true
        }
      }

      misc {
        force_default_wallpaper  = 0
        disable_hyprland_logo    = true
        animate_manual_resizes   = true
      }

      exec-once = waybar
      exec-once = nm-applet --indicator
      exec-once = mako
      exec-once = hyprpaper
      exec-once = bash -c 'sleep 2 && [ -f ~/Pictures/wallpapers/edp1.png ] && set-wallpaper-apply'
      exec-once = wl-paste --type text  --watch cliphist store
      exec-once = wl-paste --type image --watch cliphist store
      exec-once = udiskie &
      exec-once = kanshi &
      exec-once = ${assignWs}/bin/assign-ws
      exec-once = ${wsListener}/bin/ws-monitor-listener
      exec-once = /run/current-system/sw/bin/gnome-keyring-daemon --start --components=secrets
      exec-once = 1password --silent
      exec-once = ${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent

      # Core
      bind = $mod,       Return, exec, ghostty
      bind = $mod,       Escape, exec, GTK_THEME=Adwaita:dark wlogout -b 3 -c 0 -r 0 -m 0
      bind = $mod,       Space,  exec, wofi --show drun
      bind = $mod,       Q,      killactive
      bind = $mod,       F,      fullscreen
      bind = $mod,       V,      togglefloating
      bind = $mod,       P,      pseudo
      bind = $mod CTRL,  L,      exec, hyprlock
      bind = $mod,       T,      layoutmsg, togglesplit
      # Launch zen at default (1x) scale so it isn't oversized on the
      # non-HiDPI HDMI/DVI displays. MOZ_ENABLE_WAYLAND=1 already gives
      # per-monitor scaling; GDK_SCALE=1.25 (set globally for casino) makes
      # zen huge on the externals, so override it just for this launch.
      bind = $mod,       B,      exec, env GDK_SCALE=1 GDK_DPI_SCALE=1 zen-beta
      bind = $mod,       E,      exec, nautilus

      # Screenshots
      bind = ,       Print,        exec, grimblast copy area
      bind = SHIFT,  Print,        exec, grimblast copy screen
      bind = $mod SHIFT, S,        exec, grimblast save area - | swappy -f -

      # Clipboard
      bind = $mod, Y, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy

      # Focus
      bind = $mod, left,  movefocus, l
      bind = $mod, right, movefocus, r
      bind = $mod, up,    movefocus, u
      bind = $mod, down,  movefocus, d
      bind = $mod, h,     movefocus, l
      bind = $mod, l,     movefocus, r
      bind = $mod, k,     movefocus, u
      bind = $mod, j,     movefocus, d

      # Move windows
      bind = $mod SHIFT, left,  movewindow, l
      bind = $mod SHIFT, right, movewindow, r
      bind = $mod SHIFT, up,    movewindow, u
      bind = $mod SHIFT, down,  movewindow, d
      bind = $mod SHIFT, h,     movewindow, l
      bind = $mod SHIFT, l,     movewindow, r
      bind = $mod SHIFT, k,     movewindow, u
      bind = $mod SHIFT, j,     movewindow, d

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
      bind = $mod, 0, workspace, 10

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
      bind = $mod SHIFT, 0, movetoworkspace, 10

      # Scroll workspaces
      bind = $mod, mouse_down, workspace, e+1
      bind = $mod, mouse_up,   workspace, e-1

      # Audio
      bind = , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
      bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bind = , XF86AudioMute,        exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bind = , XF86AudioMicMute,     exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

      # Brightness
      bind = , XF86MonBrightnessUp,   exec, brightnessctl set 5%+
      bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

      # Media
      bind = , XF86AudioPlay, exec, playerctl play-pause
      bind = , XF86AudioNext, exec, playerctl next
      bind = , XF86AudioPrev, exec, playerctl prev

      bindm = $mod, mouse:272, movewindow
      bindm = $mod, mouse:273, resizewindow

      # blur wlogout even with global blur off — layer surfaces use their own rule
      layerrule = blur true, match:namespace wlogout
      layerrule = ignore_alpha 0.1, match:namespace wlogout

      windowrule = float on, match:class pavucontrol
      windowrule = float on, match:class blueman-manager
      windowrule = float on, match:class nm-connection-editor
      windowrule = float on, match:class 1Password
      windowrule = float on, match:class swappy
      windowrule = float on, match:title Picture-in-Picture
      windowrule = pin on,   match:title Picture-in-Picture
      windowrule = suppress_event maximize, match:class .*
    '';
  };
}
