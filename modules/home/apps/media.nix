{ config, pkgs, hostName ? "", ... }:
let
  # Casino's HiDPI laptop forces GDK_SCALE=1.25 globally, which makes
  # zen huge on the non-HiDPI HDMI/DVI displays. Wayland-native zen
  # already does per-monitor scaling, so override the env on launch.
  zenExec = if hostName == "casino"
            then "env GDK_SCALE=1 GDK_DPI_SCALE=1 zen-beta"
            else "zen-beta";
in
{
  xdg.desktopEntries.zen-beta = {
    name        = "Zen Browser (Beta)";
    genericName = "Web Browser";
    icon        = "zen-browser";
    exec        = "${zenExec} --name zen-beta %U";
    terminal    = false;
    categories  = [ "Network" "WebBrowser" ];
    mimeType    = [
      "text/html" "text/xml" "application/xhtml+xml"
      "application/vnd.mozilla.xul+xml"
      "x-scheme-handler/http" "x-scheme-handler/https"
    ];
    startupNotify = true;
    settings = { StartupWMClass = "zen-beta"; };
    actions = {
      new-private-window = {
        name = "New Private Window";
        exec = "${zenExec} --private-window %U";
      };
      new-window = {
        name = "New Window";
        exec = "${zenExec} --new-window %U";
      };
      profile-manager-window = {
        name = "Profile Manager";
        exec = "${zenExec} --ProfileManager";
      };
    };
  };

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
      "text/html"         = [ "zen-beta.desktop" ];
      "x-scheme-handler/http"  = [ "zen-beta.desktop" ];
      "x-scheme-handler/https" = [ "zen-beta.desktop" ];
    };
  };
}
