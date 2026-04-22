{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 4;

        modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right  = [
          "pulseaudio"
          "network"
          "bluetooth"
          "battery"
          "tray"
        ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "󰎤";
            "2" = "󰎧";
            "3" = "󰎪";
            "4" = "󰎭";
            "5" = "󰎱";
            "6" = "󰎳";
            "7" = "󰎶";
            "8" = "󰎹";
            "9" = "󰎼";
            urgent = "";
            active = "";
            default = "";
          };
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
        };

        "hyprland/window" = {
          max-length = 50;
          separate-outputs = true;
        };

        clock = {
          format = " {:%H:%M}";
          format-alt = " {:%A, %d %B %Y}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰸈";
          format-icons = {
            headphone = "󰋋";
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
          on-click = "pavucontrol";
          scroll-step = 5;
        };

        network = {
          format-wifi = "󰤨 {signalStrength}%";
          format-ethernet = "󰈀 {ifname}";
          format-disconnected = "󰤭";
          tooltip-format = "{ifname}: {ipaddr}\n{essid}";
          on-click = "nm-connection-editor";
        };

        bluetooth = {
          format = "󰂯 {status}";
          format-connected = "󰂱 {device_alias}";
          format-connected-battery = "󰂱 {device_alias} {device_battery_percentage}%";
          format-off = "󰂲";
          on-click = "blueman-manager";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
        };

        battery = {
          states = { warning = 30; critical = 15; };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged  = "󰚦 {capacity}%";
          format-icons    = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          tooltip-format  = "{timeTo}\n{power}W";
        };

        tray = {
          spacing = 8;
        };
      };
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background-color: #282828;
        color: #ebdbb2;
        border-bottom: 2px solid #3c3836;
      }

      /* Workspaces */
      #workspaces button {
        padding: 0 8px;
        color: #a89984;
        background-color: transparent;
      }

      #workspaces button.active {
        color: #d79921;
        background-color: #3c3836;
        border-radius: 6px;
      }

      #workspaces button.urgent {
        color: #cc241d;
      }

      #workspaces button:hover {
        background-color: #3c3836;
        border-radius: 6px;
      }

      /* Window title */
      #window {
        color: #a89984;
        padding: 0 8px;
      }

      /* Clock */
      #clock {
        color: #d79921;
        font-weight: bold;
        padding: 0 12px;
      }

      /* Right modules */
      #pulseaudio,
      #network,
      #bluetooth,
      #battery,
      #tray {
        padding: 0 10px;
        color: #ebdbb2;
      }

      #pulseaudio.muted {
        color: #928374;
      }

      #battery.warning {
        color: #fabd2f;
      }

      #battery.critical {
        color: #fb4934;
        animation: blink 0.5s linear infinite alternate;
      }

      @keyframes blink {
        to { color: #cc241d; }
      }

      #network.disconnected {
        color: #928374;
      }

      tooltip {
        background-color: #1d2021;
        border: 1px solid #d79921;
        border-radius: 6px;
        color: #ebdbb2;
      }
    '';
  };
}
