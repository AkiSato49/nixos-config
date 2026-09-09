let
  themes = {
    gruvbox-dark   = import ./gruvbox-dark.nix;
    gruvbox-prayer = import ./gruvbox-prayer.nix;
    gruvbox-light  = import ./gruvbox-light.nix;
  };
in
  themes.gruvbox-light   # ← change this one line to switch theme
