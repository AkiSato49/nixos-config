{ config, lib, pkgs, theme, ... }:

let
  c = theme.colors;
  g = theme.geometry;
  shellConfig = "lawliet-shell";
  quickshell = "${pkgs.quickshell}/bin/qs";
  shellConfigDir = pkgs.runCommand "lawliet-shell-config" { } ''
    cp -r ${./quickshell}/. "$out"
    chmod -R u+w "$out"

    cat > "$out/theme/Palette.qml" <<'QML'
    import QtQuick

    QtObject {
        readonly property color background: "${c.bg_hard}"
        readonly property color surfaceRaised: "${c.bg}"
        readonly property color surfaceHover: "${c.bg1}"
        readonly property color surfacePressed: "${c.bg2}"
        readonly property color foreground: "${c.fg}"
        readonly property color muted: "${c.fg_muted}"
        readonly property color border: "${c.bg2}"
        readonly property color accent: "${c.yellow}"
        readonly property color accentSoft: "${c.bg1}"
        readonly property color track: "${c.bg2}"
        readonly property color focus: "${c.blue}"
        readonly property color positive: "${c.green}"
        readonly property color danger: "${c.red}"
        readonly property string fontFamily: "${theme.font.ui}"
    }
    QML

    cat > "$out/theme/Metrics.qml" <<'QML'
    import QtQuick

    QtObject {
        readonly property int space2: 8
        readonly property int space3: 12
        readonly property int space4: 16
        readonly property int space6: 24
        readonly property int space8: 32
        readonly property int radiusSmall: 8
        readonly property int radiusMedium: 14
        readonly property int radiusLarge: 22
        readonly property int borderWidth: ${toString g.border_size}
        readonly property int motionMs: 180
    }
    QML
  '';

  qsShell = pkgs.writeShellApplication {
    name = "qs-shell";
    runtimeInputs = [ pkgs.systemd ];
    text = ''
      exec systemctl --user start quickshell-lawliet.service
    '';
  };

  qsControlCentre = pkgs.writeShellApplication {
    name = "qs-control-centre";
    runtimeInputs = [ pkgs.systemd pkgs.quickshell ];
    text = ''
      systemctl --user start quickshell-lawliet.service
      exec ${quickshell} -c ${shellConfig} ipc call shell openControlCentre
    '';
  };

  qsToggleControlCentre = pkgs.writeShellApplication {
    name = "qs-toggle-control-centre";
    runtimeInputs = [ pkgs.systemd pkgs.quickshell ];
    text = ''
      systemctl --user start quickshell-lawliet.service
      exec ${quickshell} -c ${shellConfig} ipc call shell toggleControlCentre
    '';
  };

  qsVolumeUp = pkgs.writeShellApplication {
    name = "qs-volume-up";
    runtimeInputs = [ pkgs.systemd pkgs.quickshell pkgs.wireplumber ];
    text = ''
      wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
      systemctl --user start quickshell-lawliet.service
      exec ${quickshell} -c ${shellConfig} ipc call shell showVolumeOsd
    '';
  };

  qsVolumeDown = pkgs.writeShellApplication {
    name = "qs-volume-down";
    runtimeInputs = [ pkgs.systemd pkgs.quickshell pkgs.wireplumber ];
    text = ''
      wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      systemctl --user start quickshell-lawliet.service
      exec ${quickshell} -c ${shellConfig} ipc call shell showVolumeOsd
    '';
  };

  qsVolumeMute = pkgs.writeShellApplication {
    name = "qs-volume-mute";
    runtimeInputs = [ pkgs.systemd pkgs.quickshell pkgs.wireplumber ];
    text = ''
      wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      systemctl --user start quickshell-lawliet.service
      exec ${quickshell} -c ${shellConfig} ipc call shell showVolumeOsd
    '';
  };

  qsMicMute = pkgs.writeShellApplication {
    name = "qs-mic-mute";
    runtimeInputs = [ pkgs.wireplumber ];
    text = ''
      exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    '';
  };

  qsBrightnessUp = pkgs.writeShellApplication {
    name = "qs-brightness-up";
    runtimeInputs = [ pkgs.systemd pkgs.quickshell pkgs.brightnessctl ];
    text = ''
      brightnessctl set 5%+
      systemctl --user start quickshell-lawliet.service
      exec ${quickshell} -c ${shellConfig} ipc call shell showBrightnessOsd
    '';
  };

  qsBrightnessDown = pkgs.writeShellApplication {
    name = "qs-brightness-down";
    runtimeInputs = [ pkgs.systemd pkgs.quickshell pkgs.brightnessctl ];
    text = ''
      brightnessctl set 5%-
      systemctl --user start quickshell-lawliet.service
      exec ${quickshell} -c ${shellConfig} ipc call shell showBrightnessOsd
    '';
  };

  qsLauncher = pkgs.writeShellApplication {
    name = "qs-launcher";
    runtimeInputs = [ pkgs.systemd pkgs.quickshell ];
    text = ''
      systemctl --user start quickshell-lawliet.service
      exec ${quickshell} -c ${shellConfig} ipc call shell toggleLauncher
    '';
  };

  qsLock = pkgs.writeShellApplication {
    name = "qs-lock";
    text = ''
      echo "qs-lock: Quickshell lockscreen is not available during Phase 0; use gtklock" >&2
      exit 1
    '';
  };
in {
  home.packages = [
    pkgs.quickshell
    qsShell qsControlCentre qsToggleControlCentre qsLauncher qsLock
    qsVolumeUp qsVolumeDown qsVolumeMute qsMicMute qsBrightnessUp qsBrightnessDown
  ];

  xdg.configFile."quickshell/${shellConfig}".source = shellConfigDir;

  systemd.user.services.quickshell-lawliet = {
    Unit = {
      Description = "Lawliet Quickshell development shell";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      StartLimitIntervalSec = 60;
      StartLimitBurst = 3;
    };
    Service = {
      ExecStart = "${quickshell} -c ${shellConfig}";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
