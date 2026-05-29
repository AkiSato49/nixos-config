{ config, pkgs, ... }:

let
  helium-browser = pkgs.appimageTools.wrapType2 rec {
    pname = "helium-browser";
    version = "0.12.4.1";

    src = pkgs.fetchurl {
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/Helium-${version}-x86_64.AppImage";
      hash = "sha256-OgS8HkLBseFrEhNFJxMwp1bg0gzPdfY1VaySAAp7vq0=";
    };

    extraPkgs = pkgs: with pkgs; [
      libsecret
      libva
    ];
  };

  helium-desktop = pkgs.makeDesktopItem {
    name = "helium-browser";
    exec = "helium-browser %U";
    icon = "chrome"; # Uses standard fallback chromium icon if custom not found
    comment = "Privacy-first, Chromium-based web browser";
    desktopName = "Helium Browser";
    genericName = "Web Browser";
    categories = [ "Network" "WebBrowser" ];
    startupWMClass = "Helium";
    mimeTypes = [ "text/html" "text/xml" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
  };
in
{
  home.packages = [
    helium-browser
    helium-desktop
  ];
}
