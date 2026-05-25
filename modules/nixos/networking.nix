{ config, pkgs, ... }:

{
  networking = {
    networkmanager.enable = true;
    modemmanager = {
      enable = true;
      fccUnlockScripts = [
        {
          id = "1eac:1007";
          path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/1eac:1007";
        }
      ];
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Syncthing
  services.syncthing = {
    enable = true;
    user = "lawliet";
    dataDir = "/home/lawliet/Sync";
    configDir = "/home/lawliet/.config/syncthing";
  };
}
