{ config, pkgs, theme, ... }:
let c = theme.colors; in {
  programs.ghostty = {
    enable = true;

    settings = {
      font-family  = theme.font.mono;
      font-size    = theme.font.size_mono;

      background-opacity = 0.95;
      window-decoration  = false;
      window-padding-x   = 14;
      window-padding-y   = 14;

      scrollback-limit = 10000;

      cursor-style          = "block";
      cursor-style-blink    = true;
      cursor-invert-fg-bg   = false;
      cursor-color          = c.yellow;

      mouse-hide-while-typing = true;

      link-url = true;

      background           = c.bg_hard;
      foreground           = c.fg;
      selection-background = c.bg1;
      selection-foreground = c.fg;

      # Gruvbox Dark Hard palette
      # Normal
      palette = [
        "0=${c.bg}"         # black
        "1=${c.red}"        # red
        "2=${c.green}"      # green
        "3=${c.yellow}"     # yellow
        "4=${c.blue}"       # blue
        "5=${c.purple}"     # magenta
        "6=${c.teal}"       # cyan
        "7=${c.fg_dim}"     # white
        # Bright
        "8=${c.gray}"       # bright black
        "9=${c.red_br}"     # bright red
        "10=${c.green_br}"  # bright green
        "11=${c.yellow_br}" # bright yellow
        "12=${c.blue_br}"   # bright blue
        "13=${c.purple_br}" # bright magenta
        "14=${c.teal_br}"   # bright cyan
        "15=${c.fg}"        # bright white
      ];

      shell-integration          = "zsh";
      shell-integration-features = "cursor,sudo,title";

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
