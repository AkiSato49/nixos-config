{ config, pkgs, ... }:

{
  networking = {
    networkmanager.enable = true;
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
