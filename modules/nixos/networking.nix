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

  # Syncthing (imperative pairing via GUI :8384; tailnet direct via tailscale0 trust)
  services.syncthing = {
    enable = true;
    user = "lawliet";
    dataDir = "/home/lawliet/.local/share/syncthing";
    configDir = "/home/lawliet/.config/syncthing";
    openDefaultPorts = true;
    overrideDevices = false; # keep GUI pairing
    overrideFolders = false; # keep GUI folders (school, etc.)
  };
}
