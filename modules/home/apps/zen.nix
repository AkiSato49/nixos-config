{ config, pkgs, lib, hostName ? "", ... }:
let
  big = hostName == "casino";
  zoom = if big then "1.6" else "1.0";
  userJs = pkgs.writeText "zen-user.js" ''
    user_pref("layout.css.devPixelsPerPx", "${zoom}");
    user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
  '';
in {
  # Push user.js into every Zen profile under ~/.config/zen
  home.activation.zenUserJs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -eu
    zenDir="$HOME/.config/zen"
    if [ -d "$zenDir" ]; then
      for prof in "$zenDir"/*/; do
        [ -d "$prof" ] || continue
        case "$(basename "$prof")" in
          "Profile Groups") continue ;;
        esac
        install -m644 ${userJs} "$prof/user.js"
      done
    fi
  '';
}
