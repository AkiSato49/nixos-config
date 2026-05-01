{ config, pkgs, theme, ... }:
let
  c       = theme.colors;
  g       = theme.geometry;
  minimal = theme.variants.hyprlock_minimal;

  # strip leading '#' from hex color for hyprlock rgb()/rgba() format
  h = s: builtins.substring 1 (builtins.stringLength s - 1) s;

  bgSettings = if minimal then {
    path              = "screenshot";
    blur_size         = 6;
    blur_passes       = 1;
    noise             = 0.0;
    contrast          = 0.9;
    brightness        = 0.28;
    vibrancy          = 0.0;
    vibrancy_darkness = 0.0;
  } else {
    path              = "screenshot";
    blur_size         = 8;
    blur_passes       = 2;
    noise             = 0.0117;
    contrast          = 0.8916;
    brightness        = 0.4;
    vibrancy          = 0.1;
    vibrancy_darkness = 0.0;
  };

  inputField = if minimal then {
    size              = "260, 38";
    position          = "0, -80";
    monitor           = "";
    dots_center       = true;
    fade_on_empty     = true;
    font_color        = "rgb(${h c.fg})";
    inner_color       = "rgb(${h c.bg_hard})";
    outer_color       = "rgb(${h c.yellow})";
    outline_thickness = 1;
    placeholder_text  = "";
    shadow_passes     = 0;
    rounding          = 0;
  } else {
    size              = "300, 50";
    position          = "0, -80";
    monitor           = "";
    dots_center       = true;
    fade_on_empty     = false;
    font_color        = "rgb(${h c.fg})";
    inner_color       = "rgb(${h c.bg})";
    outer_color       = "rgb(${h c.yellow})";
    outline_thickness = 2;
    placeholder_text  = "<span foreground='##${h c.fg}'>Password</span>";
    shadow_passes     = 2;
    rounding          = g.rounding;
  };

  # Prayer: large yellow time · uppercase date · green prompt label
  labelsMinimal = [
    {
      monitor     = "";
      text        = ''cmd[update:1000] echo "$(date +"%H:%M")"'';
      color       = "rgba(${h c.yellow}ff)";
      font_size   = 80;
      font_family = "${theme.font.ui} Bold";
      position    = "0, 140";
      halign      = "center";
      valign      = "center";
      shadow_passes = 0;
    }
    {
      monitor     = "";
      text        = ''cmd[update:60000] echo "$(date +"%A · %d %B %Y" | tr "[:lower:]" "[:upper:]")"'';
      color       = "rgba(${h c.fg_dim}ff)";
      font_size   = 13;
      font_family = theme.font.ui;
      position    = "0, 60";
      halign      = "center";
      valign      = "center";
      shadow_passes = 0;
    }
    {
      monitor     = "";
      text        = "> authenticate";
      color       = "rgba(${h c.teal_br}ff)";
      font_size   = 11;
      font_family = theme.font.ui;
      position    = "0, -28";
      halign      = "center";
      valign      = "center";
      shadow_passes = 0;
    }
  ];

  # Dark: bold white time + muted date
  labelsStandard = [
    {
      monitor     = "";
      text        = ''cmd[update:1000] echo "<b><big>$(date +"%H:%M")</big></b>"'';
      color       = "rgba(${h c.fg}ff)";
      font_size   = 64;
      font_family = "${theme.font.ui} Bold";
      position    = "0, 160";
      halign      = "center";
      valign      = "center";
      shadow_passes = 2;
    }
    {
      monitor     = "";
      text        = ''cmd[update:1000] echo "$(date +"%A, %B %d")"'';
      color       = "rgba(${h c.fg_dim}ff)";
      font_size   = 20;
      font_family = theme.font.ui;
      position    = "0, 80";
      halign      = "center";
      valign      = "center";
      shadow_passes = 2;
    }
  ];
in {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
      };

      background    = [ bgSettings ];
      "input-field" = [ inputField ];
      label         = if minimal then labelsMinimal else labelsStandard;
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd    = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd           = "hyprlock";
      };
      listener = [
        {
          timeout    = 300;
          on-timeout = "hyprlock";
        }
        {
          timeout    = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume  = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
