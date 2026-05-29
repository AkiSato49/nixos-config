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

  # NixOS ignores the [Install] section of units added via systemd.packages,
  # so ModemManager never gets a multi-user.target.wants symlink automatically.
  # Add wantedBy explicitly so it starts at boot before NetworkManager sees modems.
  systemd.services.ModemManager = {
    wantedBy = [ "multi-user.target" ];
    before   = [ "NetworkManager.service" ];
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
