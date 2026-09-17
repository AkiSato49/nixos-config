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

      auth = {
        fingerprint = {
          enabled = true;
        };
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
        # Single lock owner = hypridle. Noctalia lock_before_suspend=false
        # (see noctalia.nix); hypridle alone drives suspend + idle lock.
        # Singular `lock-session` (no ID) locks caller's own session with no
        # auth prompt — but only resolves while $XDG_SESSION_ID is in the
        # user manager env (Hyprland exec-once imports it, then restarts
        # hypridle). Plural `lock-sessions` hits all sessions and demands
        # polkit auth — never use it here.
        # lock_cmd goes direct to Noctalia IPC with hyprlock fallback so a
        # dead Noctalia never means an unlocked session.
        before_sleep_cmd = "loginctl lock-session";
        inhibit_sleep = 3;
        ignore_dbus_inhibit = false;
        lock_cmd = "sh -c 'noctalia msg session lock || hyprlock'";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          # Monitors black only — never suspend the box. Lock already held
          # since 300s; DPMS off is display-only, session stays up.
          on-timeout = "hyprctl dispatch dpms off";
          # Single DPMS writer (after_sleep_cmd removed). Settle delay:
          # DPMS wake re-announces wl_output globals in stages
          # (kanshi pair -> triple took ~3s Sep 14); firing dpms on
          # immediately races noctalia bar/wallpaper rebuild and kills it
          # (wl_display invalid object -> exit 1). 5s lets kanshi settle.
          on-resume = "sleep 5 && hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
