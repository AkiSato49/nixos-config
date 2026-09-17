{ pkgs, ... }:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
    };
  };

  home.packages = [
    pkgs.imagemagick

    # Apply already-generated wallpapers (runs on login)
    (pkgs.writeShellScriptBin "set-wallpaper-apply" ''
      WP_DIR="$HOME/Pictures/wallpapers"
      fallback="$WP_DIR/edp1.png"
      if ! ${pkgs.imagemagick}/bin/magick identify "$fallback" >/dev/null 2>&1; then
        echo "No valid wallpapers found at $WP_DIR — run set-wallpaper <image> first"
        exit 1
      fi
      while IFS=$'\t' read -r name description; do
        case "$description" in
          "Lenovo Group Limited Pro 27Q-10 UGW1F5CA") image="$WP_DIR/dp9.png" ;;
          "AOC Q27G2SG4B+ OGJMBHA018485") image="$WP_DIR/dp10.png" ;;
          *) image="$fallback" ;;
        esac
        # Never leave an output blank because one generated tile was truncated.
        if ! ${pkgs.imagemagick}/bin/magick identify "$image" >/dev/null 2>&1; then
          echo "Invalid wallpaper $image; using $fallback" >&2
          image="$fallback"
        fi
        hyprctl hyprpaper wallpaper "$name,$image"
      done < <(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | [.name, .description] | @tsv')
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

      generate() {
        destination="$1"
        size="$2"
        gravity="$3"
        temporary=$(mktemp "$WP_DIR/.wallpaper.XXXXXX.png")
        trap 'rm -f "$temporary"' RETURN
        $CONVERT "$SRC" \
          -resize "$size^" \
          -gravity "$gravity" \
          -extent "$size" \
          "$temporary"
        mv "$temporary" "$destination"
        trap - RETURN
      }

      # Write through temporary files: interrupted conversion cannot replace a
      # valid tile with a truncated PNG.
      echo "Generating eDP-1 (laptop, left)..."
      generate "$WP_DIR/edp1.png" "2880x1800" West

      echo "Generating Lenovo 27Q (centre)..."
      generate "$WP_DIR/dp9.png" "2560x1440" Center

      echo "Generating AOC Q27G2 (right, portrait)..."
      generate "$WP_DIR/dp10.png" "1440x2560" East

      # Current protocol loads paths when assigning them; explicit preload and
      # unload requests belong to older hyprpaper versions.
      echo "Applying wallpapers..."
      while IFS=$'\t' read -r name description; do
        case "$description" in
          "Lenovo Group Limited Pro 27Q-10 UGW1F5CA") image="$WP_DIR/dp9.png" ;;
          "AOC Q27G2SG4B+ OGJMBHA018485") image="$WP_DIR/dp10.png" ;;
          *) image="$WP_DIR/edp1.png" ;;
        esac
        hyprctl hyprpaper wallpaper "$name,$image"
      done < <(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | [.name, .description] | @tsv')

      echo "Done! Wallpapers saved to $WP_DIR."
    '')
  ];
}
