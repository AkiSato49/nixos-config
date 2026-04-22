{ config, pkgs, ... }:

{
  services.mako = {
    enable = true;
    settings = {
      background-color = "#282828";
      text-color       = "#ebdbb2";
      border-color     = "#d79921";
      border-radius    = 8;
      border-size      = 2;
      default-timeout  = 5000;
      font             = "JetBrainsMono Nerd Font 11";
      width            = 360;
      padding          = "12";
      margin           = "10";
      icon-path        = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";

      "[urgency=high]" = {
        border-color    = "#fb4934";
        default-timeout = 0;
      };

      "[urgency=low]" = {
        border-color = "#3c3836";
      };
    };
  };
}
