{ config, pkgs, ... }:

{
  # DisplayLink USB dock support
  services.xserver.videoDrivers = [ "displaylink" "modesetting" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.evdi ];
}
