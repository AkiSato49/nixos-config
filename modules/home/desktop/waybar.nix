{ config, pkgs, theme, hostName ? "", ... }:
let
  c    = theme.colors;
  f    = theme.font;
  g    = theme.geometry;
  flat = theme.variants.waybar_flat;

  # HiDPI laptop: bump everything up.
  big      = hostName == "casino";
  uiSize   = if big then 16 else f.size_ui;
  smSize   = if big then 14 else 11;
  barH     = if big then 44 else 36;
  wsMin    = if big then 28 else 24;
  wsFont   = if big then 15 else 12;

  clockFmt = if flat then "{:%H:%M}" else " {:%H:%M}";
  clockAlt = if flat then "{:%A  %d %B %Y}" else " {:%A, %d %B %Y}";

  # ── Swiss flat style (prayer theme) ─────────────────────────────────────────
  styleFlat = ''
    * {
      font-family: "${f.ui}";
      font-size: ${toString uiSize}px;
      border: none;
      border-radius: 0;
      min-height: 0;
    }

    window#waybar {
      background-color: rgba(249, 245, 215, 0.86);
      color: ${c.fg};
      border-bottom: 1px solid rgba(60, 56, 54, 0.12);
    }

    /* Workspaces ── flat, underline accent */
    #workspaces {
      margin: 0;
      padding: 0;
      background: transparent;
    }

    #workspaces button {
      padding: 0 10px;
      margin: 3px 1px;
      color: ${c.fg_muted};
      background-color: transparent;
      border-radius: 7px;
      border-bottom: 2px solid transparent;
      font-size: ${toString smSize}px;
      font-weight: bold;
      transition: color 0.15s ease, border-bottom-color 0.15s ease;
    }

    #workspaces button.empty  { color: ${c.bg1}; }

    #workspaces button.active {
      color: ${c.fg};
      border-bottom-color: ${c.yellow};
    }

    #workspaces button.urgent {
      color: ${c.red_br};
      border-bottom-color: ${c.red};
    }

    #workspaces button:hover {
      color: ${c.yellow};
      background-color: transparent;
      border-bottom-color: ${c.yellow};
    }

    /* Window title */
    #window {
      color: ${c.fg_dim};
      padding: 0 8px;
      font-size: ${toString smSize}px;
    }

    /* Clock ── typography forward */
    #clock {
      color: ${c.fg};
      font-weight: 700;
      padding: 0 16px;
      letter-spacing: 0.02em;
    }

    /* Right modules ── no bg, left-border separators */
    #pulseaudio,
    #network,
    #bluetooth,
    #battery,
    #tray,
    #custom-launcher,
    #custom-control-center {
      padding: 0 9px;
      color: ${c.fg_dim};
      background: transparent;
    }

    #custom-launcher {
      color: ${c.fg};
      font-size: ${toString uiSize}px;
      font-weight: 700;
    }

    #custom-control-center {
      margin: 4px 8px 4px 2px;
      padding: 0 10px;
      color: ${c.fg};
      background: ${c.bg1};
      border-radius: 999px;
    }

    #custom-launcher:hover,
    #custom-control-center:hover {
      background: ${c.bg2};
    }

    #pulseaudio           { color: ${c.fg}; }
    #pulseaudio.muted     { color: ${c.bg2}; }

    #network.wifi         { color: ${c.teal_br}; }   /* water — connected */
    #network.ethernet     { color: ${c.blue_br}; }   /* sky   — wired */
    #network.disconnected { color: ${c.bg2}; }

    #bluetooth            { color: ${c.fg_dim}; }
    #bluetooth.connected  { color: ${c.blue_br}; }   /* sky   — bt */
    #bluetooth.off        { color: ${c.bg2}; }

    #battery              { color: ${c.fg}; }
    #battery.charging     { color: ${c.teal_br}; }   /* water — charging */
    #battery.warning      { color: ${c.yellow_br}; }
    #battery.critical {
      color: ${c.red_br};
      animation: blink 0.5s linear infinite alternate;
    }

    @keyframes blink { to { color: ${c.red}; } }

    tooltip {
      background-color: ${c.bg};
      border: 1px solid ${c.yellow};
      border-radius: ${toString g.rounding}px;
      color: ${c.fg};
      font-size: ${toString smSize}px;
    }
  '';

  # ── Pill style (gruvbox-dark theme) ─────────────────────────────────────────
  stylePill = ''
    * {
      font-family: "${f.ui}";
      font-size: ${toString uiSize}px;
      border: none;
      border-radius: 0;
      min-height: 0;
    }

    window#waybar {
      background-color: #1d2021;
      color: #ebdbb2;
      border-bottom: 2px solid #282828;
    }

    #workspaces {
      margin: 4px 6px;
      padding: 0 4px;
      background-color: #282828;
      border-radius: 10px;
      border: 1px solid #3c3836;
    }

    #workspaces button {
      padding: 0 10px;
      margin: 2px 1px;
      min-width: ${toString wsMin}px;
      color: #ebdbb2;
      background-color: transparent;
      border-radius: 6px;
      font-size: ${toString wsFont}px;
      font-weight: bold;
      transition: background-color 0.18s ease, color 0.18s ease;
    }

    #workspaces button.empty  { color: #3c3836; }

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

    #window {
      color: #665c54;
      padding: 0 8px;
      font-style: italic;
    }

    #clock {
      color: #d79921;
      font-weight: bold;
      padding: 0 12px;
    }

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

    #pulseaudio.muted     { color: #928374; }
    #battery.warning      { color: #fabd2f; }
    #battery.critical {
      color: #fb4934;
      animation: blink 0.5s linear infinite alternate;
    }

    @keyframes blink { to { color: #cc241d; } }

    #network.disconnected { color: #928374; }

    tooltip {
      background-color: #1d2021;
      border: 1px solid #d79921;
      border-radius: 6px;
      color: #ebdbb2;
    }
  '';
in {
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer    = "top";
        position = "top";
        height   = barH;
        spacing  = 4;

        modules-left   = [ "custom/launcher" "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right  = [ "custom/control-center" "tray" ];

        "custom/launcher" = {
          format = "◉";
          tooltip = false;
          on-click = "wofi --show drun";
        };

        "custom/control-center" = {
          format = "󰕾  󰤨  󰂯  󰁹";
          tooltip = true;
          tooltip-format = "Control Center";
          on-click = "control-center-toggle";
        };


        "hyprland/workspaces" = {
          format = "{id}<span size='7000' rise='-3500'>{windows}</span>";
          format-window-separator = "";
          window-rewrite-default  = "󰣆";
          window-rewrite = {
            "class<zen-beta> title<.*YouTube.*>"  = "󰗃";
            "class<zen-beta> title<.*Twitch.*>"   = "󰕃";
            "class<zen-beta> title<.*GitHub.*>"   = "󰊤";
            "class<zen-beta> title<.*Reddit.*>"   = "󰑍";
            "class<zen-beta> title<.*Twitter.*>"  = "󰕄";
            "class<zen-beta> title<.*Gmail.*>"    = "󰊫";
            "class<zen-beta> title<.*Google.*>"   = "󰊭";
            "class<zen-beta> title<.*ChatGPT.*>"  = "󱙺";
            "class<zen-beta> title<.*Claude.*>"   = "󱙺";
            "class<zen-beta> title<.*Figma.*>"    = "󰶡";
            "class<zen-beta> title<.*Canva.*>"    = "󰏘";
            "class<zen-beta> title<.*Canvas.*>"   = "󰑴";
            "class<zen-beta> title<.*edstem.*>"   = "󱂮";
            "class<zen-beta> title<.*Ed .*>"      = "󱂮";
            "class<zen-beta> title<.*Notion.*>"   = "󱉹";
            "class<zen-beta> title<.*Spotify.*>"  = "󰓇";
            "class<zen-beta> title<.*LinkedIn.*>" = "󰌻";
            "class<zen-beta> title<.*Outlook.*>"  = "󰴢";
            "class<zen-beta> title<.*Teams.*>"    = "󰊻";
            "class<zen-beta> title<.*PDF.*>"      = "󰈦";
            "class<zen-beta> title<.*Stack.*>"    = "󰓌";
            "class<zen-beta>"                     = "";

            "class<com.mitchellh.ghostty> title<.*ssh.*>"  = "󰣀";
            "class<com.mitchellh.ghostty> title<.*nvim.*>" = "";
            "class<com.mitchellh.ghostty> title<.*git.*>"  = "󰊤";
            "class<com.mitchellh.ghostty>"                 = "";
            "class<Alacritty> title<.*ssh.*>"              = "󰣀";
            "class<Alacritty> title<.*nvim.*>"             = "";
            "class<Alacritty>"                             = "";

            "class<code>"          = "󰨞";
            "class<code-oss>"      = "󰨞";
            "class<cursor>"        = "󰨞";
            "class<obsidian>"      = "󱞋";
            "class<vesktop>"       = "󰙯";
            "class<discord>"       = "󰙯";
            "class<spotify>"       = "󰓇";
            "class<mpv>"           = "";
            "class<vlc>"           = "󰕼";
            "class<nautilus>"      = "󰉋";
            "class<libreoffice.*>" = "󰈙";
            "class<gimp.*>"        = "󰏘";
            "class<darktable>"     = "󰄄";
            "class<qbittorrent>"   = "󰋮";
            "class<steam>"         = "󰓓";
            "class<firefox>"              = "󰈹";
            "class<org.pwmt.zathura>"     = "󰈦";
            "class<imv>"                  = "󰋩";
          };
          # Workspaces are assigned dynamically per-monitor by assign-ws,
          # so just show whichever ones land on each output.
          separate-outputs    = true;
          on-scroll-up        = "hyprctl dispatch workspace e+1";
          on-scroll-down      = "hyprctl dispatch workspace e-1";
          show-special        = false;
          active-only         = false;
        };

        "hyprland/window" = {
          max-length       = 50;
          separate-outputs = true;
        };

        clock = {
          format     = clockFmt;
          format-alt = clockAlt;
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        pulseaudio = {
          format       = "{icon}";
          format-muted = "󰸈";
          format-icons = {
            headphone = "󰋋";
            default   = [ "󰕿" "󰖀" "󰕾" ];
          };
          on-click   = "l1p0-menus --toggle audio";
          scroll-step = 5;
        };

        network = {
          format-wifi       = "󰤨";
          format-ethernet   = "󰈀";
          format-disconnected = "󰤭";
          tooltip-format    = "{ifname}: {ipaddr}\n{essid}";
          on-click          = "l1p0-menus --toggle network";
        };

        bluetooth = {
          format                    = "󰂯";
          format-connected          = "󰂱";
          format-connected-battery  = "󰂱";
          format-off                = "󰂲";
          on-click                  = "l1p0-menus --toggle bluetooth";
          tooltip-format            = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected  = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
        };

        battery = {
          states          = { warning = 30; critical = 15; };
          format          = "{icon}";
          format-charging = "󰂄";
          format-plugged  = "󰚦";
          format-icons    = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          tooltip-format  = "{timeTo}\n{power}W";
          on-click        = "l1p0-menus --toggle battery";
        };

        tray = { spacing = 8; };
      };
    };

    style = if flat then styleFlat else stylePill;
  };

  systemd.user.services.waybar = {
    Service = {
      Restart = pkgs.lib.mkForce "always";
      RestartSec = "2";
    };
  };
}
