{ config, pkgs, theme, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding        = { x = 14; y = 14; };
        opacity        = 1.0;
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
        size    = theme.font.size_mono;
      };

      # Matches Noctalia's built-in `Noctalia` palette in light mode.
      colors = {
        primary = {
          background = "#e6e8fa";
          foreground = "#4b55c8";
        };
        cursor = {
          text   = "#e6e8fa";
          cursor = "#5d65f5";
        };
        selection = {
          text       = "#e6e8fa";
          background = "#4b55c8";
        };
        normal = {
          black   = "#eff0ff";
          red     = "#FD4663";
          green   = "#0e0e43";
          yellow  = "#5d65f5";
          blue    = "#8E93D8";
          magenta = "#FD4663";
          cyan    = "#0e0e43";
          white   = "#4b55c8";
        };
        bright = {
          black   = "#8288fc";
          red     = "#FD4663";
          green   = "#0e0e43";
          yellow  = "#5d65f5";
          blue    = "#8E93D8";
          magenta = "#FD4663";
          cyan    = "#0e0e43";
          white   = "#0e0e43";
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

      selection = {
        save_to_clipboard = false;
      };

      keyboard.bindings = [
        { key = "V";    mods = "Control|Shift"; action = "Paste"; }
        { key = "C";    mods = "Control|Shift"; action = "Copy"; }
        { key = "V";    mods = "Super";         action = "Paste"; }
        { key = "C";    mods = "Super";         action = "Copy"; }
        { key = "Plus"; mods = "Control";       action = "IncreaseFontSize"; }
        { key = "Minus"; mods = "Control";      action = "DecreaseFontSize"; }
        { key = "Key0"; mods = "Control";       action = "ResetFontSize"; }
      ];
    };
  };
}
