{ config, pkgs, ... }:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      # Add your wallpaper path here
      # preload = [ "~/.config/hypr/wallpaper.jpg" ];
      # wallpaper = [ ",~/.config/hypr/wallpaper.jpg" ];
    };
  };

  # Default: solid gruvbox dark bg as fallback
  home.file.".config/hypr/wallpaper-fallback.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Generate a solid gruvbox dark wallpaper if none set
      if [ ! -f ~/.config/hypr/wallpaper.jpg ]; then
        ${pkgs.imagemagick}/bin/convert -size 1920x1080 xc:'#1d2021' ~/.config/hypr/wallpaper.jpg
        hyprpaper --preload ~/.config/hypr/wallpaper.jpg
        hyprpaper --wallpaper ",~/.config/hypr/wallpaper.jpg"
      fi
    '';
  };
}
