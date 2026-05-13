{ config, pkgs, ... }:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [
        "~/Pictures/wallpapers/edp1.png"
        "~/Pictures/wallpapers/dp9.png"
        "~/Pictures/wallpapers/dp10.png"
      ];
      wallpaper = [
        "eDP-1,~/Pictures/wallpapers/edp1.png"
        "desc:Lenovo Group Limited Pro 27Q-10 UGW1F5CA,~/Pictures/wallpapers/dp9.png"
        "desc:AOC Q27G2SG4B+ OGJMBHA018485,~/Pictures/wallpapers/dp10.png"
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
      hyprctl hyprpaper preload "$WP_DIR/dp9.png"
      hyprctl hyprpaper preload "$WP_DIR/dp10.png"
      hyprctl hyprpaper wallpaper "eDP-1,$WP_DIR/edp1.png"
      hyprctl hyprpaper wallpaper "desc:Lenovo Group Limited Pro 27Q-10 UGW1F5CA,$WP_DIR/dp9.png"
      hyprctl hyprpaper wallpaper "desc:AOC Q27G2SG4B+ OGJMBHA018485,$WP_DIR/dp10.png"
    '')
    (pkgs.writeShellScriptBin "set-wallpaper" ''
      # Wallpaper per monitor — matched by description, not DP port number.
      #
      # Monitor physical resolutions:
      #   eDP-1       : 2880x1800  (scale 1.5, logical 1920x1200, aspect 16:10)
      #   Lenovo 27Q  : 2560x1440  (scale 1, logical 2560x1440, aspect 16:9)
      #   AOC Q27G2   : 2560x1440  (scale 1, rotated 270°, portrait 1440x2560 logical)

      SRC="$1"
      if [ -z "$SRC" ] || [ ! -f "$SRC" ]; then
        echo "Usage: set-wallpaper <image>"
        exit 1
      fi

      WP_DIR="$HOME/Pictures/wallpapers"
      mkdir -p "$WP_DIR"
      CONVERT="${pkgs.imagemagick}/bin/convert"

      # --- eDP-1 (left, laptop): 2880x1800, 16:10 ---
      echo "Generating eDP-1 (laptop, left)..."
      $CONVERT "$SRC" \
        -resize "2880x1800^" \
        -gravity West \
        -extent "2880x1800" \
        "$WP_DIR/edp1.png"

      # --- Lenovo Pro 27Q (centre): 2560x1440, 16:9 ---
      echo "Generating Lenovo 27Q (centre)..."
      $CONVERT "$SRC" \
        -resize "2560x1440^" \
        -gravity Center \
        -extent "2560x1440" \
        "$WP_DIR/dp9.png"

      # --- AOC Q27G2 (right, portrait): 1440x2560 ---
      echo "Generating AOC Q27G2 (right, portrait)..."
      $CONVERT "$SRC" \
        -resize "1440x2560^" \
        -gravity East \
        -extent "1440x2560" \
        "$WP_DIR/dp10.png"

      # Apply via hyprpaper IPC
      echo "Applying wallpapers..."
      hyprctl hyprpaper unload all 2>/dev/null
      hyprctl hyprpaper preload "$WP_DIR/edp1.png"
      hyprctl hyprpaper preload "$WP_DIR/dp9.png"
      hyprctl hyprpaper preload "$WP_DIR/dp10.png"
      hyprctl hyprpaper wallpaper "eDP-1,$WP_DIR/edp1.png"
      hyprctl hyprpaper wallpaper "desc:Lenovo Group Limited Pro 27Q-10 UGW1F5CA,$WP_DIR/dp9.png"
      hyprctl hyprpaper wallpaper "desc:AOC Q27G2SG4B+ OGJMBHA018485,$WP_DIR/dp10.png"

      echo "Done! Wallpapers saved to $WP_DIR."
    '')
  ];
}
