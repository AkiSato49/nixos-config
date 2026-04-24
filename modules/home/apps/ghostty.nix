{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;

    settings = {
      # Font
      font-family      = "JetBrainsMono Nerd Font";
      font-size        = 13.5;

      # Window
      background-opacity  = 0.95;
      window-decoration   = false;
      window-padding-x    = 14;
      window-padding-y    = 14;

      # Scrollback
      scrollback-limit = 10000;

      # Cursor
      cursor-style          = "block";
      cursor-style-blink    = true;
      cursor-invert-fg-bg   = false;
      cursor-color          = "#d79921";

      # Mouse
      mouse-hide-while-typing = true;

      # Gruvbox Dark Hard
      background            = "#1d2021";
      foreground            = "#ebdbb2";
      selection-background  = "#3c3836";
      selection-foreground  = "#ebdbb2";

      palette = [
        # Normal
        "0=#282828"   # black
        "1=#cc241d"   # red
        "2=#98971a"   # green
        "3=#d79921"   # yellow
        "4=#458588"   # blue
        "5=#b16286"   # magenta
        "6=#689d6a"   # cyan
        "7=#a89984"   # white
        # Bright
        "8=#928374"   # bright black
        "9=#fb4934"   # bright red
        "10=#b8bb26"  # bright green
        "11=#fabd2f"  # bright yellow
        "12=#83a598"  # bright blue
        "13=#d3869b"  # bright magenta
        "14=#8ec07c"  # bright cyan
        "15=#ebdbb2"  # bright white
      ];

      # Shell integration
      shell-integration     = "zsh";
      shell-integration-features = "cursor,sudo,title";

      # Keybindings
      keybind = [
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+equal=increase_font_size:1"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+zero=reset_font_size"
      ];
    };
  };
}
