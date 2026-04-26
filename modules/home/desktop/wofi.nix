{ config, pkgs, theme, ... }:
let
  c    = theme.colors;
  g    = theme.geometry;
  flat = theme.variants.waybar_flat;

  # rounding helpers
  winR   = if g.rounding > 0 then "10px" else "0";
  inputR = if g.rounding > 0 then "8px"  else "0";
  entryR = if g.rounding > 0 then "6px"  else "0";

  selExtra = if flat
    then "border-left: 2px solid ${c.yellow}; border-radius: 0; background-color: ${c.bg};"
    else "";

  # ── Power menu script ────────────────────────────────────────────────────────
  powerMenu = pkgs.writeShellScriptBin "power-menu" ''
    choice=$(printf '%s\n' \
      "<span foreground='${c.yellow}'>LOCK</span>" \
      "<span foreground='${c.blue_br}'>SUSPEND</span>" \
      "<span foreground='${c.blue_br}'>HIBERNATE</span>" \
      "<span foreground='${c.fg}'>LOGOUT</span>" \
      "<span foreground='${c.teal_br}'>REBOOT</span>" \
      "<span foreground='${c.red_br}'>SHUTDOWN</span>" \
      | ${pkgs.wofi}/bin/wofi \
          --dmenu \
          --prompt "" \
          --allow-markup \
          --insensitive \
          --style "$HOME/.config/wofi/power.css" \
          --conf "$HOME/.config/wofi/power-conf")

    case "$choice" in
      *LOCK*)      hyprlock ;;
      *SUSPEND*)   systemctl suspend ;;
      *HIBERNATE*) systemctl hibernate ;;
      *LOGOUT*)    hyprctl dispatch exit ;;
      *REBOOT*)    systemctl reboot ;;
      *SHUTDOWN*)  systemctl poweroff ;;
    esac
  '';

  # ── Power menu wofi config ───────────────────────────────────────────────────
  powerConf = ''
    width=700
    height=500
    location=center
    show=dmenu
    prompt=
    filter_rate=100
    allow_markup=true
    insensitive=true
    allow_images=false
    hide_scroll=true
    no_actions=true
    halign=fill
    content_halign=center
    orientation=vertical
    gtk_dark=true
  '';

  # ── Power menu CSS ───────────────────────────────────────────────────────────
  powerCss = ''
    * {
      font-family: "${theme.font.ui}";
      font-size: 48px;
      border: none;
      border-radius: 0;
    }

    window {
      margin: 0;
      border: 1px solid ${c.yellow};
      background-color: ${c.bg_hard};
    }

    /* hide the search input — not needed for a power menu */
    #input {
      min-height: 0;
      max-height: 0;
      padding: 0;
      margin: 0;
      border: none;
      opacity: 0;
    }

    #outer-box {
      margin: 0;
      padding: 48px 0;
      background: transparent;
    }

    #inner-box { background: transparent; }

    #scroll { margin: 0; }

    #entry {
      padding: 20px 0;
      background: transparent;
    }

    #entry:selected {
      background-color: ${c.bg1};
    }

    #text {
      color: ${c.fg_muted};
      padding: 0;
    }

    /* keep pango color on selection, just change background */
    #text:selected { color: inherit; }
  '';
in {
  home.packages = [ powerMenu ];

  xdg.configFile."wofi/power-conf".text = powerConf;
  xdg.configFile."wofi/power.css".text  = powerCss;

  programs.wofi = {
    enable = true;
    settings = {
      width          = 600;
      height         = 400;
      location       = "center";
      show           = "drun";
      prompt         = "Search...";
      filter_rate    = 100;
      allow_markup   = true;
      no_actions     = true;
      halign         = "fill";
      orientation    = "vertical";
      content_halign = "fill";
      insensitive    = true;
      allow_images   = true;
      image_size     = 32;
      gtk_dark       = true;
    };

    style = ''
      * {
        font-family: "${theme.font.ui}";
        font-size: 14px;
      }

      window {
        margin: 0;
        border: ${toString g.border_size}px solid ${c.yellow};
        background-color: ${c.bg_hard};
        border-radius: ${winR};
      }

      #input {
        margin: 8px;
        padding: 8px 16px;
        background-color: ${c.bg};
        color: ${c.fg};
        border-radius: ${inputR};
        border: 1px solid ${c.bg1};
        outline: none;
      }

      #input:focus { border-color: ${c.yellow}; }

      #inner-box {
        margin: 4px;
        background-color: transparent;
      }

      #outer-box {
        margin: 0;
        padding: 4px;
        background-color: transparent;
      }

      #scroll { margin: 0 4px 4px 4px; }

      #text {
        color: ${c.fg};
        padding: 4px 8px;
      }

      #entry {
        border-radius: ${entryR};
        padding: 4px;
      }

      #entry:selected {
        background-color: ${c.bg1};
        ${selExtra}
      }

      #text:selected { color: ${c.yellow}; }

      #img { margin-right: 8px; }
    '';
  };
}
