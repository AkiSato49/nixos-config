{ config, pkgs, ... }:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [
        "~/.config/hypr/wallpapers/edp1.png"
        "~/.config/hypr/wallpapers/hdmi.png"
        "~/.config/hypr/wallpapers/dvi.png"
      ];
      wallpaper = [
        "eDP-1,~/.config/hypr/wallpapers/edp1.png"
        "HDMI-A-1,~/.config/hypr/wallpapers/hdmi.png"
        "DVI-I-1,~/.config/hypr/wallpapers/dvi.png"
      ];
    };
  };

  home.packages = [
    pkgs.imagemagick
    (pkgs.writeShellScriptBin "set-wallpaper" ''
      #!/bin/bash
      # Splits a single image across eDP-1 | HDMI-A-1 | DVI-I-1 (rotated 270°)
      # Monitor layout (logical px):
      #   eDP-1:    1440 x 900   (physical 2880x1800, scale 2)
      #   HDMI-A-1: 2560 x 1440  (physical 2560x1440, scale 1)
      #   DVI-I-1:  1440 x 2560  (physical 2560x1440, scale 1, rotated 270°)

      SRC="$1"
      if [ -z "$SRC" ] || [ ! -f "$SRC" ]; then
        echo "Usage: set-wallpaper <image>"
        exit 1
      fi

      WP_DIR="$HOME/.config/hypr/wallpapers"
      mkdir -p "$WP_DIR"

      # Logical dimensions (hardcoded for this monitor layout)
      # eDP-1: 1440x900  |  HDMI-A-1: 2560x1440  |  DVI-I-1: 1440x2560 (portrait)
      # Total width: 5440, ref height: 2560

      echo "Scaling source image to 5440x2560..."
      SCALED="$(mktemp /tmp/wallpaper-XXXX.png)"
      ${pkgs.imagemagick}/bin/convert "$SRC" \
        -resize "5440x2560^" \
        -gravity Center \
        -extent "5440x2560" \
        "$SCALED"

      # eDP-1: center-crop 1440x900 from left, scale 2x to physical 2880x1800
      echo "Generating eDP-1 wallpaper..."
      ${pkgs.imagemagick}/bin/convert "$SCALED" \
        -crop "1440x900+0+830" \
        -resize "2880x1800!" \
        "$WP_DIR/edp1.png"

      # HDMI-A-1: center-crop 2560x1440 from middle
      echo "Generating HDMI-A-1 wallpaper..."
      ${pkgs.imagemagick}/bin/convert "$SCALED" \
        -crop "2560x1440+1440+560" \
        "$WP_DIR/hdmi.png"

      # DVI-I-1: full-height 1440x2560 from right, rotate 90° CW so
      # Hyprland's 270° display transform shows it correctly
      echo "Generating DVI-I-1 wallpaper..."
      ${pkgs.imagemagick}/bin/convert "$SCALED" \
        -crop "1440x2560+4000+0" \
        -rotate 90 \
        "$WP_DIR/dvi.png"

      rm -f "$SCALED"

      # Apply via hyprpaper IPC
      echo "Applying wallpapers..."
      hyprctl hyprpaper unload all 2>/dev/null
      hyprctl hyprpaper preload "$WP_DIR/edp1.png"
      hyprctl hyprpaper preload "$WP_DIR/hdmi.png"
      hyprctl hyprpaper preload "$WP_DIR/dvi.png"
      hyprctl hyprpaper wallpaper "eDP-1,$WP_DIR/edp1.png"
      hyprctl hyprpaper wallpaper "HDMI-A-1,$WP_DIR/hdmi.png"
      hyprctl hyprpaper wallpaper "DVI-I-1,$WP_DIR/dvi.png"

      echo "Done! Wallpaper set across all monitors."
    '')
  ];
}
