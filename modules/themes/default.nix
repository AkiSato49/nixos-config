let
  themes = {
    gruvbox-dark   = import ./gruvbox-dark.nix;
    gruvbox-prayer = import ./gruvbox-prayer.nix;
  };
in
  themes.gruvbox-prayer   # ← change this one line to switch theme
