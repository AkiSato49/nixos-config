{ config, pkgs, ... }:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [
        "~/Pictures/wallpapers/edp1.png"
        "~/Pictures/wallpapers/hdmi.png"
        "~/Pictures/wallpapers/dvi.png"
      ];
      wallpaper = [
        "eDP-1,~/Pictures/wallpapers/edp1.png"
        "HDMI-A-1,~/Pictures/wallpapers/hdmi.png"
        "DVI-I-1,~/Pictures/wallpapers/dvi.png"
      ];
    };
  };

  home.packages = [
    pkgs.imagemagick

    # Apply already-generated wallpapers (runs on login)
    (pkgs.writeShellScriptBin "set-wallpaper-apply" ''
      WP_DIR="$HOME/Pictures/wallpapers"
      if [ ! -f "$WP_DIR/edp1.png" ]; then
        echo "No wallpapers found at $WP_DIR — run set-wallpaper <image> first"
        exit 1
      fi
      hyprctl hyprpaper unload all 2>/dev/null
      hyprctl hyprpaper preload "$WP_DIR/edp1.png"
      hyprctl hyprpaper preload "$WP_DIR/hdmi.png"
      hyprctl hyprpaper preload "$WP_DIR/dvi.png"
      hyprctl hyprpaper wallpaper "eDP-1,$WP_DIR/edp1.png"
      hyprctl hyprpaper wallpaper "HDMI-A-1,$WP_DIR/hdmi.png"
      hyprctl hyprpaper wallpaper "DVI-I-1,$WP_DIR/dvi.png"
    '')
    (pkgs.writeShellScriptBin "set-wallpaper" ''
      # Panoramic wallpaper across eDP-1 | HDMI-A-1 | DVI-I-1 (portrait)
      # Each monitor gets a full, beautiful section scaled to fill its aspect ratio.
      # Overlap is intentional — continuity over strict tiling.
      #
      # Monitor physical resolutions:
      #   eDP-1:    2880x1800  (scale 2, logical 1440x900,  aspect 16:10)
      #   HDMI-A-1: 2560x1440  (scale 1, logical 2560x1440, aspect 16:9)
      #   DVI-I-1:  2560x1440  (scale 1, rotated 270°, portrait 1440x2560 logical)

      SRC="$1"
      if [ -z "$SRC" ] || [ ! -f "$SRC" ]; then
        echo "Usage: set-wallpaper <image>"
        exit 1
      fi

      WP_DIR="$HOME/Pictures/wallpapers"
      mkdir -p "$WP_DIR"
      CONVERT="${pkgs.imagemagick}/bin/convert"

      # --- eDP-1 (left monitor): 2880x1800, 16:10 ---
      echo "Generating eDP-1 (laptop, left)..."
      $CONVERT "$SRC" \
        -resize "2880x1800^" \
        -gravity West \
        -extent "2880x1800" \
        "$WP_DIR/edp1.png"

      # --- HDMI-A-1 (centre monitor): 2560x1440, 16:9 ---
      echo "Generating HDMI-A-1 (centre, Lenovo)..."
      $CONVERT "$SRC" \
        -resize "2560x1440^" \
        -gravity Center \
        -extent "2560x1440" \
        "$WP_DIR/hdmi.png"

      # --- DVI-I-1 (right monitor, portrait): logical 1440x2560 ---
      echo "Generating DVI-I-1 (right, portrait)..."
      $CONVERT "$SRC" \
        -resize "1440x2560^" \
        -gravity East \
        -extent "1440x2560" \
        "$WP_DIR/dvi.png"

      # Apply via hyprpaper IPC
      echo "Applying wallpapers..."
      hyprctl hyprpaper unload all 2>/dev/null
      hyprctl hyprpaper preload "$WP_DIR/edp1.png"
      hyprctl hyprpaper preload "$WP_DIR/hdmi.png"
      hyprctl hyprpaper preload "$WP_DIR/dvi.png"
      hyprctl hyprpaper wallpaper "eDP-1,$WP_DIR/edp1.png"
      hyprctl hyprpaper wallpaper "HDMI-A-1,$WP_DIR/hdmi.png"
      hyprctl hyprpaper wallpaper "DVI-I-1,$WP_DIR/dvi.png"

      echo "Wallpapers saved to $WP_DIR — will persist across rebuilds."

      echo "Done!"
    '')
  ];
}
