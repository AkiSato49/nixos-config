{ lib, pkgs, ... }:

{
  services.mongodb = {
    enable = true;
    package = pkgs.mongodb-ce;
    bind_ip = "127.0.0.1";
    # Port defaults to 27017.
  };

  # Keep MongoDB installed, but avoid running it through every battery session.
  # Start when needed with: sudo systemctl start mongodb
  systemd.services.mongodb.wantedBy = lib.mkForce [ ];
}
