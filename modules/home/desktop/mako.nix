{ config, pkgs, ... }:

{
  services.mako = {
    enable = true;
    backgroundColor = "#282828";
    textColor = "#ebdbb2";
    borderColor = "#d79921";
    borderRadius = 8;
    borderSize = 2;
    defaultTimeout = 5000;
    font = "JetBrainsMono Nerd Font 11";
    width = 360;
    padding = "12";
    margin = "10";
    iconPath = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";

    extraConfig = ''
      [urgency=high]
      border-color=#fb4934
      default-timeout=0

      [urgency=low]
      border-color=#3c3836
    '';
  };
}
