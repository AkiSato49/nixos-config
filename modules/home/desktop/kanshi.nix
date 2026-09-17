{ config, pkgs, hostName ? "", ... }:

{
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";

    # Per-host split: casino owns eDP profiles, mambo owns externals only.
    # Shared file previously fed casino eDP criteria to mambo where they
    # never match (dead weight + profile ambiguity on DPMS wake).
    settings =
      if hostName == "casino" then [
        # Laptop only
        {
          profile.name = "undocked";
          profile.outputs = [
            { criteria = "eDP-1"; status = "enable"; scale = 1.5; }
          ];
        }

        # Docked: Samsung left + laptop + Lenovo + AOC portrait right.
        # Positions match hyprland logical-pixel layout:
        #   Samsung : 2560x1440 / scale 1,   at 0,0
        #   eDP-1   : 2880x1800 / scale 1.5 -> 1920x1200 logical, at 2560,0
        #   Lenovo  : 2560x1440 / scale 1,   at 4480,0
        #   AOC     : 2560x1440 / scale 1,   portrait (transform 3), at 7040,0
        {
          profile.name = "docked";
          profile.outputs = [
            { criteria = "Samsung Electric Company Odyssey G50SF HNAL600304"; status = "enable"; scale = 1.0; position = "0,0"; }
            { criteria = "eDP-1";                                  status = "enable"; scale = 1.5; position = "2560,0"; }
            { criteria = "Lenovo Group Limited Pro 27Q-10 UGW1F5CA"; status = "enable"; scale = 1.0; position = "4480,0"; }
            { criteria = "AOC Q27G2SG4B+ OGJMBHA018485";            status = "enable"; scale = 1.0; position = "7040,0"; transform = "270"; }
          ];
        }
      ] else [
        # External triple: Samsung left + Lenovo main + AOC portrait right.
        {
          profile.name = "external-triple";
          profile.outputs = [
            { criteria = "Samsung Electric Company Odyssey G50SF HNAL600304"; status = "enable"; scale = 1.0; position = "0,0"; }
            { criteria = "Lenovo Group Limited Pro 27Q-10 UGW1F5CA"; status = "enable"; scale = 1.0; position = "2560,0"; }
            { criteria = "AOC Q27G2SG4B+ OGJMBHA018485";            status = "enable"; scale = 1.0; position = "5120,0"; transform = "270"; }
          ];
        }

        # External pair keeps triple-layout coordinates. If Lenovo shifts to
        # 0,0 here, returning Samsung first appears at its pinned 0,0 and
        # overlaps Lenovo until kanshi switches to external-triple. Stable
        # coordinates also avoid moving two live outputs during DPMS wake.
        {
          profile.name = "external-pair";
          profile.outputs = [
            { criteria = "Lenovo Group Limited Pro 27Q-10 UGW1F5CA"; status = "enable"; scale = 1.0; position = "2560,0"; }
            { criteria = "AOC Q27G2SG4B+ OGJMBHA018485";            status = "enable"; scale = 1.0; position = "5120,0"; transform = "270"; }
          ];
        }
      ];
  };
}
