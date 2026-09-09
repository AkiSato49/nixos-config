{ config, lib, pkgs, inputs, theme, hostName ? "", ... }:
let
  c = theme.colors;
  g = theme.geometry;
  workspaceState = "${config.xdg.stateHome}/hypr/workspaces.conf";

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
      #   Lenovo Pro 27Q  : 2560x1440 / scale 1, landscape, at 1920,0
      #   AOC Q27G2SG4B+  : 2560x1440 / scale 1, portrait (270°), at 4480,0
      #   desc: matching avoids DP port number churn on replug
      monitor = eDP-1, 2880x1800@60, 0x0, ${edpScale}
      monitor = desc:Lenovo Group Limited Pro 27Q-10 UGW1F5CA, 2560x1440@60, 1920x0, 1
      monitor = desc:AOC Q27G2SG4B+ OGJMBHA018485,            2560x1440@60, 4480x0, 1, transform, 3
    '' else "";

  # Each Super+B press opens a new Zen window, including when Zen already runs.
  # No launch lock: its file descriptor survives exec into Zen, blocking every
  # later keypress for lifetime of browser process.
  launchZen = pkgs.writeShellScriptBin "launch-zen" ''
    exec ${pkgs.coreutils}/bin/env GDK_SCALE=1 GDK_DPI_SCALE=1 zen-beta --new-window
  '';

  # Generate workspace rules from complete monitor topology. Rules live in a
  # sourced state file because Hyprland 0.54 does not replace workspace rules
  # through repeated `hyprctl keyword workspace` calls.
  assignWs = pkgs.writeShellScriptBin "assign-ws" ''
    set -euo pipefail
    HYPRCTL=${pkgs.hyprland}/bin/hyprctl
    JQ=${pkgs.jq}/bin/jq

    exec 9>"$XDG_RUNTIME_DIR/assign-ws.lock"
    ${pkgs.util-linux}/bin/flock 9

    monitor_json=$($HYPRCTL monitors -j)
    n=$(printf '%s' "$monitor_json" | $JQ 'length')
    if [ "$n" -eq 0 ]; then
      echo "assign-ws: no monitors connected" >&2
      exit 0
    fi

    declare -a mons counts
    if [ "${if big then "1" else "0"}" = 1 ] && [ "$n" -eq 3 ] \
      && printf '%s' "$monitor_json" | $JQ -e \
        'any(.[]; .description == "Lenovo Group Limited Pro 27Q-10 UGW1F5CA") and
         any(.[]; .name == "eDP-1") and
         any(.[]; .description == "AOC Q27G2SG4B+ OGJMBHA018485")' >/dev/null; then
      # Docked casino: main Lenovo gets 1-4, laptop 5-7, portrait AOC 8-10.
      mons+=("$(printf '%s' "$monitor_json" | $JQ -r '.[] | select(.description == "Lenovo Group Limited Pro 27Q-10 UGW1F5CA") | .name')")
      mons+=("eDP-1")
      mons+=("$(printf '%s' "$monitor_json" | $JQ -r '.[] | select(.description == "AOC Q27G2SG4B+ OGJMBHA018485") | .name')")
      counts=(4 3 3)
    else
      # Any other setup: split 10 evenly across outputs, left-to-right.
      mapfile -t mons < <(printf '%s' "$monitor_json" | $JQ -r 'sort_by(.x) | .[].name')
      base=$(( 10 / n ))
      extra=$(( 10 % n ))
      for i in "''${!mons[@]}"; do
        count=$base
        [ "$i" -lt "$extra" ] && count=$(( count + 1 ))
        counts+=("$count")
      done
    fi

    mkdir -p "$(dirname '${workspaceState}')"
    tmp=$(mktemp '${workspaceState}.XXXXXX')
    declare -A targets first
    ws=1
    for i in "''${!mons[@]}"; do
      mon="''${mons[$i]}"
      count="''${counts[$i]}"
      first[$mon]=$ws
      for ((j = 1; j <= count; j++)); do
        default=""
        [ "$j" -eq 1 ] && default=", default:true"
        printf 'workspace = %d, monitor:%s%s\n' "$ws" "$mon" "$default" >> "$tmp"
        targets[$ws]=$mon
        ws=$(( ws + 1 ))
      done
    done
    mv "$tmp" '${workspaceState}'

    # Reload clears stale rules, then move workspaces which already exist.
    $HYPRCTL reload >/dev/null
    sleep 0.2
    workspaces=$($HYPRCTL workspaces -j)
    for ws in "''${!targets[@]}"; do
      if printf '%s' "$workspaces" | $JQ -e --argjson ws "$ws" 'any(.[]; .id == $ws)' >/dev/null; then
        $HYPRCTL dispatch moveworkspacetomonitor "$ws ''${targets[$ws]}" >/dev/null 2>&1 || true
      fi
    done

    # Replace automatic workspaces (11+) and any workspace left on the wrong
    # output while topology was still changing.
    focused=$($HYPRCTL activeworkspace -j | $JQ -r '.monitor')
    for mon in "''${mons[@]}"; do
      active=$($HYPRCTL monitors -j | $JQ -r --arg mon "$mon" '.[] | select(.name == $mon) | .activeWorkspace.id')
      if [ "''${targets[$active]:-}" != "$mon" ]; then
        $HYPRCTL dispatch focusmonitor "$mon" >/dev/null
        $HYPRCTL dispatch workspace "''${first[$mon]}" >/dev/null
      fi
    done
    $HYPRCTL dispatch focusmonitor "$focused" >/dev/null 2>&1 || true

    echo "assign-ws: ''${mons[*]} -> ''${counts[*]}" >&2
  '';

  toggleFloatWindow = pkgs.writeShellScriptBin "toggle-float-window" ''
    set -eu
    HYPRCTL=${pkgs.hyprland}/bin/hyprctl
    JQ=${pkgs.jq}/bin/jq

    floating=$($HYPRCTL activewindow -j | $JQ -r '.floating // false')
    $HYPRCTL dispatch togglefloating

    # Apply placement only when entering floating mode; preserve an existing
    # floating window's geometry when returning it to tiled mode.
    if [ "$floating" != "true" ]; then
      $HYPRCTL dispatch resizeactive exact 33% 33%
      $HYPRCTL dispatch centerwindow 1
    fi
  '';

  wsListener = pkgs.writeShellScriptBin "ws-monitor-listener" ''
    set -u
    SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    pending=""

    schedule_update() {
      if [ -n "$pending" ]; then
        kill "$pending" 2>/dev/null || true
      fi
      (
        # Dock outputs arrive as several events; wait for complete topology.
        sleep 2
        ${assignWs}/bin/assign-ws
        ${config.home.profileDirectory}/bin/set-wallpaper-apply
      ) &
      pending=$!
    }

    ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:"$SOCK" | while IFS= read -r line; do
      case "$line" in
        monitoradded*|monitorremoved*) schedule_update ;;
      esac
    done
  '';

  smartClipboard = pkgs.writeShellScriptBin "smart-clipboard" ''
    set -e
    action="$1" # "copy" or "paste"
    HYPRCTL="${pkgs.hyprland}/bin/hyprctl"
    JQ="${pkgs.jq}/bin/jq"

    class=$($HYPRCTL activewindow -j | $JQ -r '.class | ascii_downcase')

    if [ "$class" = "alacritty" ]; then
      if [ "$action" = "copy" ]; then
        $HYPRCTL dispatch sendshortcut CTRL_SHIFT, c, activewindow
      else
        $HYPRCTL dispatch sendshortcut CTRL_SHIFT, v, activewindow
      fi
    else
      if [ "$action" = "copy" ]; then
        $HYPRCTL dispatch sendshortcut CTRL, c, activewindow
      else
        $HYPRCTL dispatch sendshortcut CTRL, v, activewindow
      fi
    fi
  '';
in {
  home.packages = [ assignWs ];

  wayland.windowManager.hyprland = {
    enable  = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    systemd.enable = true;

    extraConfig = ''
      ${monitorConfig}
      source = ${workspaceState}

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
      env = TERMINAL,alacritty

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
        active_opacity = ${toString (g.active_opacity or 1.0)}
        inactive_opacity = ${toString (g.inactive_opacity or 1.0)}
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

      exec-once = nm-applet --indicator
      exec-once = hyprpaper
      exec-once = bash -c 'sleep 2 && [ -f ~/Pictures/wallpapers/edp1.png ] && set-wallpaper-apply'
      exec-once = wl-paste --type text  --watch cliphist store
      exec-once = wl-paste --type image --watch cliphist store
      exec-once = udiskie &
      exec-once = ${assignWs}/bin/assign-ws
      exec-once = /run/current-system/sw/bin/gnome-keyring-daemon --start --components=secrets
      exec-once = 1password --silent

      # Core
      bind = $mod,       Return, exec, alacritty
      bind = $mod,       Escape, exec, noctalia msg panel-toggle session
      bind = $mod,       Space,  exec, noctalia msg panel-toggle launcher
      bind = $mod,       Q,      killactive
      bind = $mod,       F,      fullscreen
      bind = $mod,       F2,     togglefloating
      bind = $mod,       C,      exec, ${smartClipboard}/bin/smart-clipboard copy
      bind = $mod,       V,      exec, ${smartClipboard}/bin/smart-clipboard paste
      bind = $mod,       P,      pseudo
      bind = $mod CTRL,  L,      exec, noctalia msg session lock
      # Keep tested GTKLock as explicit recovery path while Noctalia lock is proven.
      bind = $mod CTRL SHIFT, L, exec, gtklock
      bind = $mod CTRL,  C,      exec, noctalia msg panel-toggle control-center
      bind = $mod,       T,      layoutmsg, togglesplit
      # Start Zen at default scale, or focus existing Zen. Launch lock absorbs
      # duplicate key events before second browser window can open.
      bind = $mod,       B,      exec, ${launchZen}/bin/launch-zen
      bind = $mod,       E,      exec, nautilus

      # Screenshots
      bind = ,       Print,        exec, grimblast copy area
      bind = SHIFT,  Print,        exec, grimblast copy screen
      bind = $mod SHIFT, S,        exec, grimblast save area - | swappy -f -

      # Clipboard
      bind = $mod, Y, exec, noctalia msg panel-toggle clipboard

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

      # Noctalia owns volume, microphone, brightness actions, and OSD.
      bind = , XF86AudioRaiseVolume, exec, noctalia msg volume-up
      bind = , XF86AudioLowerVolume, exec, noctalia msg volume-down
      bind = , XF86AudioMute,        exec, noctalia msg volume-mute
      bind = , XF86AudioMicMute,     exec, noctalia msg mic-mute

      bind = , XF86MonBrightnessUp,   exec, noctalia msg brightness-up
      bind = , XF86MonBrightnessDown, exec, noctalia msg brightness-down

      # Media
      bind = , XF86AudioPlay, exec, playerctl play-pause
      bind = , XF86AudioNext, exec, playerctl next
      bind = , XF86AudioPrev, exec, playerctl prev

      bindm = $mod, mouse:272, movewindow
      bindm = $mod, mouse:273, resizewindow
      # Rear thumb button (BTN_BACK): hold, then drag to move focused window.
      bindm = , mouse:278, movewindow
      # Middle thumb button, or Ctrl+left-click: float at 1/3 monitor size,
      # centered. Existing floating windows return to tiled mode unchanged.
      bind = , mouse:276, exec, ${toggleFloatWindow}/bin/toggle-float-window
      bind = CTRL, mouse:272, exec, ${toggleFloatWindow}/bin/toggle-float-window

      # Let Noctalia own panel animation; Hyprland supplies translucent blur.
      layerrule = no_anim true, match:namespace ^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$
      layerrule = blur true, match:namespace ^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$
      layerrule = ignore_alpha 0.5, match:namespace ^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$

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

  home.activation.hyprWorkspaceState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$(dirname '${workspaceState}')"
    if [ ! -e '${workspaceState}' ]; then
      : > '${workspaceState}'
    fi
  '';

  systemd.user.services.ws-monitor-listener = {
    Unit = {
      Description = "Reconfigure workspaces and wallpapers on monitor hotplug";
      After = [ "hyprland-session.target" "hyprpaper.service" ];
      PartOf = [ "hyprland-session.target" ];
    };
    Service = {
      ExecStartPre = "-${pkgs.procps}/bin/pkill -f /ws-monitor-listener/bin/ws-monitor-listener";
      ExecStart = "${wsListener}/bin/ws-monitor-listener";
      Restart = "always";
      RestartSec = 2;
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };
}
