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
          format = "{id}<span size='7000' rise='-3500'>{windows}</span>";
          format-window-separator = "";
          window-rewrite-default = "󰣆";
          window-rewrite = {
            # ── Zen Browser (title-aware) ──────────────────────────────
            "class<zen-beta> title<.*YouTube.*>"    = "󰗃";
            "class<zen-beta> title<.*Twitch.*>"     = "󰕃";
            "class<zen-beta> title<.*GitHub.*>"     = "󰊤";
            "class<zen-beta> title<.*Reddit.*>"     = "󰑍";
            "class<zen-beta> title<.*Twitter.*>"    = "󰕄";
            "class<zen-beta> title<.*Gmail.*>"      = "󰊫";
            "class<zen-beta> title<.*Google.*>"     = "󰊭";
            "class<zen-beta> title<.*ChatGPT.*>"    = "󱙺";
            "class<zen-beta> title<.*Claude.*>"     = "󱙺";
            "class<zen-beta> title<.*Figma.*>"      = "󰶡";
            "class<zen-beta> title<.*Canva.*>"      = "󰏘";
            "class<zen-beta> title<.*Canvas.*>"     = "󰑴";
            "class<zen-beta> title<.*edstem.*>"     = "󱂮";
            "class<zen-beta> title<.*Ed .*>"        = "󱂮";
            "class<zen-beta> title<.*Notion.*>"     = "󱉹";
            "class<zen-beta> title<.*Spotify.*>"    = "󰓇";
            "class<zen-beta> title<.*LinkedIn.*>"   = "󰌻";
            "class<zen-beta> title<.*Outlook.*>"    = "󰴢";
            "class<zen-beta> title<.*Teams.*>"      = "󰊻";
            "class<zen-beta> title<.*PDF.*>"        = "󰈦";
            "class<zen-beta> title<.*Stack.*>"      = "󰓌";
            "class<zen-beta>"                       = "";  # generic zen

            # ── Terminal (title-aware) ─────────────────────────────────
            "class<com.mitchellh.ghostty> title<.*ssh.*>"  = "󰣀";
            "class<com.mitchellh.ghostty> title<.*nvim.*>" = "";
            "class<com.mitchellh.ghostty> title<.*git.*>"  = "󰊤";
            "class<com.mitchellh.ghostty>"                 = "";
            "class<Alacritty> title<.*ssh.*>"              = "󰣀";
            "class<Alacritty> title<.*nvim.*>"             = "";
            "class<Alacritty>"                             = "";

            # ── Dev tools ─────────────────────────────────────────────
            "class<code>"             = "󰨞";
            "class<code-oss>"         = "󰨞";
            "class<cursor>"           = "󰨞";

            # ── Apps ──────────────────────────────────────────────────
            "class<obsidian>"         = "󱞋";
            "class<vesktop>"          = "󰙯";
            "class<discord>"          = "󰙯";
            "class<spotify>"          = "󰓇";
            "class<mpv>"              = "";
            "class<vlc>"              = "󰕼";
            "class<nautilus>"         = "󰉋";
            "class<libreoffice.*>"    = "󰈙";
            "class<gimp.*>"           = "󰏘";
            "class<darktable>"        = "󰄄";
            "class<qbittorrent>"      = "󰋮";
            "class<steam>"            = "󰓓";
            "class<firefox>"              = "󰈹";
            "class<org.pwmt.zathura>"     = "󰈦";
            "class<imv>"                  = "󰋩";
          };
          persistent-workspaces = {
            "eDP-1"    = [ 1 2 3 ];
            "HDMI-A-1" = [ 4 5 6 ];
            "DVI-I-1"  = [ 7 8 9 ];
          };
          separate-outputs    = true;
          on-scroll-up        = "hyprctl dispatch workspace e+1";
          on-scroll-down      = "hyprctl dispatch workspace e-1";
          show-special        = false;
          active-only         = false;
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
        background-color: #1d2021;
        color: #ebdbb2;
        border-bottom: 2px solid #282828;
      }

      /* Workspaces — pill container per monitor */
      #workspaces {
        margin: 4px 6px;
        padding: 0 4px;
        background-color: #282828;
        border-radius: 10px;
        border: 1px solid #3c3836;
      }

      /* All buttons identical size — no layout shift ever */
      #workspaces button {
        padding: 0 10px;
        margin: 2px 1px;
        min-width: 24px;
        color: #ebdbb2;
        background-color: transparent;
        border-radius: 6px;
        font-size: 12px;
        font-weight: bold;
        /* glide: smooth color + background transitions only */
        transition: background-color 0.18s ease, color 0.18s ease;
      }

      /* Empty workspaces — dim down */
      #workspaces button.empty {
        color: #3c3836;
      }

      /* Active: bright gold pill — same padding as others, no shift */
      #workspaces button.active {
        color: #1d2021;
        background-color: #d79921;
      }

      #workspaces button.urgent {
        color: #1d2021;
        background-color: #cc241d;
      }

      #workspaces button:hover {
        color: #ebdbb2;
        background-color: #3c3836;
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

      /* Window title */
      #window {
        color: #665c54;
        padding: 0 8px;
        font-style: italic;
      }

      /* Right modules */
      #pulseaudio,
      #network,
      #bluetooth,
      #battery,
      #tray {
        padding: 0 10px;
        margin: 4px 2px;
        color: #ebdbb2;
        background-color: #282828;
        border-radius: 6px;
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
