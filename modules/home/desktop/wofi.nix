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

  # strip '#' from hex for fuzzel's RRGGBBAA format
  h = s: builtins.substring 1 (builtins.stringLength s - 1) s;

  # ── Power menu script (fuzzel) ───────────────────────────────────────────────
  powerMenu = pkgs.writeShellScriptBin "power-menu" ''
    choice=$(printf '%s\n' \
      "LOCK" \
      "SUSPEND" \
      "HIBERNATE" \
      "LOGOUT" \
      "REBOOT" \
      "SHUTDOWN" \
      | ${pkgs.fuzzel}/bin/fuzzel \
          --dmenu \
          --prompt="" \
          --font="${theme.font.ui}:size=48" \
          --background="${h c.bg_hard}ff" \
          --text-color="${h c.fg_muted}ff" \
          --selection-color="${h c.bg1}ff" \
          --selection-text-color="${h c.yellow}ff" \
          --match-color="${h c.yellow}ff" \
          --border-color="${h c.yellow}ff" \
          --border-width=1 \
          --border-radius=0 \
          --lines=6 \
          --width=14 \
          --no-sort)

    case "$choice" in
      LOCK)      hyprlock ;;
      SUSPEND)   systemctl suspend ;;
      HIBERNATE) systemctl hibernate ;;
      LOGOUT)    hyprctl dispatch exit ;;
      REBOOT)    systemctl reboot ;;
      SHUTDOWN)  systemctl poweroff ;;
    esac
  '';
in {
  home.packages = [ powerMenu pkgs.fuzzel ];

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
