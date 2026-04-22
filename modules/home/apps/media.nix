{ config, pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    config = {
      profile       = "gpu-hq";
      gpu-context   = "wayland";
      hwdec         = "auto-safe";
      vo            = "gpu";
      ao            = "pipewire";
      sub-auto      = "fuzzy";
      volume-max    = 150;
      save-position-on-quit = true;
    };
  };

  programs.zathura = {
    enable = true;
    options = {
      default-bg          = "#1d2021";
      default-fg          = "#ebdbb2";
      statusbar-bg        = "#282828";
      statusbar-fg        = "#ebdbb2";
      inputbar-bg         = "#282828";
      inputbar-fg         = "#ebdbb2";
      notification-bg     = "#282828";
      notification-fg     = "#ebdbb2";
      highlight-color     = "#d79921";
      highlight-active-color = "#fabd2f";
      selection-clipboard = "clipboard";
      recolor             = true;
      recolor-darkcolor   = "#ebdbb2";
      recolor-lightcolor  = "#1d2021";
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "video/mp4"         = [ "mpv.desktop" ];
      "video/mkv"         = [ "mpv.desktop" ];
      "video/x-matroska"  = [ "mpv.desktop" ];
      "video/webm"        = [ "mpv.desktop" ];
      "image/jpeg"        = [ "imv.desktop" ];
      "image/png"         = [ "imv.desktop" ];
      "image/gif"         = [ "imv.desktop" ];
      "image/webp"        = [ "imv.desktop" ];
      "application/pdf"   = [ "org.pwmt.zathura.desktop" ];
      "text/html"         = [ "zen.desktop" ];
      "x-scheme-handler/http"  = [ "zen.desktop" ];
      "x-scheme-handler/https" = [ "zen.desktop" ];
    };
  };
}
