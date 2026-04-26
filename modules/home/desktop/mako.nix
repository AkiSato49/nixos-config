{ config, pkgs, theme, ... }:
let
  c = theme.colors;
  g = theme.geometry;
in {
  services.mako = {
    enable = true;
    settings = {
      background-color = c.bg;
      text-color       = c.fg;
      border-color     = c.yellow;
      border-radius    = g.rounding;
      border-size      = g.border_size;
      default-timeout  = 5000;
      font             = "${theme.font.ui} 11";
      width            = 360;
      padding          = "12";
      margin           = "10";
      icon-path        = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";
    };

    extraConfig = ''
      [urgency=high]
      border-color=${c.red_br}
      default-timeout=0

      [urgency=low]
      border-color=${c.bg1}
    '';
  };
}
