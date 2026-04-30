{ config, pkgs, theme, hostName ? "", ... }:
let
  c = theme.colors;
  big = hostName == "casino";
  monoSize = if big then 22 else theme.font.size_mono;
in {
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding        = { x = 14; y = 14; };
        opacity        = 0.95;
        decorations    = "None";
        startup_mode   = "Windowed";
        title          = "Alacritty";
        dynamic_title  = true;
      };

      scrolling = {
        history    = 10000;
        multiplier = 3;
      };

      font = {
        normal  = { family = theme.font.mono; style = "Regular"; };
        bold    = { family = theme.font.mono; style = "Bold"; };
        italic  = { family = theme.font.mono; style = "Italic"; };
        size    = monoSize;
      };

      colors = {
        primary = {
          background = c.bg_hard;
          foreground = c.fg;
        };
        cursor = {
          text   = c.bg;
          cursor = c.yellow;
        };
        selection = {
          text       = c.fg;
          background = c.bg1;
        };
        normal = {
          black   = c.bg;
          red     = c.red;
          green   = c.green;
          yellow  = c.yellow;
          blue    = c.blue;
          magenta = c.purple;
          cyan    = c.teal;
          white   = c.fg_dim;
        };
        bright = {
          black   = c.gray;
          red     = c.red_br;
          green   = c.green_br;
          yellow  = c.yellow_br;
          blue    = c.blue_br;
          magenta = c.purple_br;
          cyan    = c.teal_br;
          white   = c.fg;
        };
      };

      cursor = {
        style = {
          shape    = "Block";
          blinking = "On";
        };
        vi_mode_style    = "Underline";
        blink_interval   = 750;
        unfocused_hollow = true;
      };

      mouse.hide_when_typing = true;

      keyboard.bindings = [
        { key = "V";    mods = "Control|Shift"; action = "Paste"; }
        { key = "C";    mods = "Control|Shift"; action = "Copy"; }
        { key = "Plus"; mods = "Control";       action = "IncreaseFontSize"; }
        { key = "Minus"; mods = "Control";      action = "DecreaseFontSize"; }
        { key = "Key0"; mods = "Control";       action = "ResetFontSize"; }
      ];
    };
  };
}
