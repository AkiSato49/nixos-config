{ config, pkgs, ... }:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      # Uncomment and set your wallpaper:
      # preload = [ "~/.config/hypr/wallpaper.jpg" ];
      # wallpaper = [ ",~/.config/hypr/wallpaper.jpg" ];
    };
  };

  # Generate a solid gruvbox dark wallpaper on first boot if none is set
  # Run manually: ~/.config/hypr/init-wallpaper.sh
  home.file.".config/hypr/init-wallpaper.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      WALLPAPER="$HOME/.config/hypr/wallpaper.jpg"
      if [ ! -f "$WALLPAPER" ]; then
        ${pkgs.imagemagick}/bin/convert -size 1920x1080 xc:'#1d2021' "$WALLPAPER"
        hyprctl hyprpaper preload "$WALLPAPER"
        hyprctl hyprpaper wallpaper ",$WALLPAPER"
      fi
    '';
  };
}
