{ config, pkgs, ... }:

{
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";

    profiles = {
      # Laptop only
      undocked = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.0;
          }
        ];
      };

      # TODO: Add your monitor IDs after running `hyprctl monitors`
      # You can get criteria strings with `kanshi` and checking /var/log
      # Example multi-monitor profiles below — fill in your actual monitor names:

      # one_external = {
      #   outputs = [
      #     { criteria = "eDP-1"; status = "enable"; position = "0,1080"; }
      #     { criteria = "Dell U2720Q"; status = "enable"; position = "0,0"; scale = 1.5; }
      #   ];
      # };

      # three_external = {
      #   outputs = [
      #     { criteria = "eDP-1"; status = "disable"; }
      #     { criteria = "Monitor-1"; status = "enable"; position = "0,0"; }
      #     { criteria = "Monitor-2"; status = "enable"; position = "2560,0"; }
      #     { criteria = "Monitor-3"; status = "enable"; position = "5120,0"; }
      #   ];
      # };
    };
  };
}
