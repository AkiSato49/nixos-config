{ config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = { x = 14; y = 14; };
        opacity = 0.95;
        decorations = "None";
        startup_mode = "Windowed";
        title = "Alacritty";
        dynamic_title = true;
      };

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      font = {
        normal  = { family = "JetBrainsMono Nerd Font"; style = "Regular"; };
        bold    = { family = "JetBrainsMono Nerd Font"; style = "Bold"; };
        italic  = { family = "JetBrainsMono Nerd Font"; style = "Italic"; };
        size = 13.5;
      };

      # Gruvbox Dark Hard
      colors = {
        primary = {
          background = "#1d2021";
          foreground = "#ebdbb2";
        };
        cursor = {
          text   = "#282828";
          cursor = "#d79921";
        };
        selection = {
          text       = "#ebdbb2";
          background = "#3c3836";
        };
        normal = {
          black   = "#282828";
          red     = "#cc241d";
          green   = "#98971a";
          yellow  = "#d79921";
          blue    = "#458588";
          magenta = "#b16286";
          cyan    = "#689d6a";
          white   = "#a89984";
        };
        bright = {
          black   = "#928374";
          red     = "#fb4934";
          green   = "#b8bb26";
          yellow  = "#fabd2f";
          blue    = "#83a598";
          magenta = "#d3869b";
          cyan    = "#8ec07c";
          white   = "#ebdbb2";
        };
      };

      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        vi_mode_style = "Underline";
        blink_interval = 750;
        unfocused_hollow = true;
      };

      mouse = {
        hide_when_typing = true;
      };

      keyboard.bindings = [
        { key = "V";        mods = "Control|Shift"; action = "Paste"; }
        { key = "C";        mods = "Control|Shift"; action = "Copy"; }
        { key = "Plus";     mods = "Control";       action = "IncreaseFontSize"; }
        { key = "Minus";    mods = "Control";       action = "DecreaseFontSize"; }
        { key = "Key0";     mods = "Control";       action = "ResetFontSize"; }
      ];
    };
  };
}
