{ config, pkgs, ... }:

{
  services.mongodb = {
    enable   = true;
    package  = pkgs.mongodb-ce;
    bind_ip  = "127.0.0.1";
    # port defaults to 27017
  };
}
