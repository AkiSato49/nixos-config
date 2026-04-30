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
          { criteria = "eDP-1"; status = "enable"; scale = 1.75; }
        ];
      }

      # TODO: fill in your monitor names after running `hyprctl monitors`
      # Example multi-monitor profiles:

      # {
      #   profile.name = "one_external";
      #   profile.outputs = [
      #     { criteria = "eDP-1"; status = "enable"; position = "0,1080"; }
      #     { criteria = "Dell U2720Q"; status = "enable"; position = "0,0"; scale = 1.5; }
      #   ];
      # }

      # {
      #   profile.name = "three_external";
      #   profile.outputs = [
      #     { criteria = "eDP-1"; status = "disable"; }
      #     { criteria = "Monitor-1"; status = "enable"; position = "0,0"; }
      #     { criteria = "Monitor-2"; status = "enable"; position = "2560,0"; }
      #     { criteria = "Monitor-3"; status = "enable"; position = "5120,0"; }
      #   ];
      # }
    ];
  };
}
