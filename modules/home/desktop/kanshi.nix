{ config, pkgs, ... }:

{
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";

    settings = [
      # Laptop only
      {
        profile.name = "undocked";
        profile.outputs = [
          { criteria = "eDP-1"; status = "enable"; scale = 1.5; }
        ];
      }

      # Docked: laptop + Lenovo Pro 27Q (centre) + AOC Q27G2SG4B+ (right, portrait)
      # Positions match hyprland logical-pixel layout:
      #   eDP-1   : 2880x1800 / scale 1.5 -> 1920x1200 logical, at 0,0
      #   Lenovo  : 2560x1440 / scale 1,   at 1920,0
      #   AOC     : 2560x1440 / scale 1,   portrait (transform 3), at 4480,0
      {
        profile.name = "docked";
        profile.outputs = [
          { criteria = "eDP-1";                                  status = "enable"; scale = 1.5; position = "0,0"; }
          { criteria = "Lenovo Group Limited Pro 27Q-10 UGW1F5CA"; status = "enable"; scale = 1.0; position = "1920,0"; }
          { criteria = "AOC Q27G2SG4B+ OGJMBHA018485";            status = "enable"; scale = 1.0; position = "4480,0"; transform = "270"; }
        ];
      }
    ];
  };
}
