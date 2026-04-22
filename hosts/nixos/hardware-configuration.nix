# ============================================================
# PLACEHOLDER — DO NOT USE AS-IS
# ============================================================
# When you boot the NixOS installer on your machine, run:
#
#   sudo nixos-generate-config --root /mnt
#
# Then copy /mnt/etc/nixos/hardware-configuration.nix here
# and replace this file entirely.
# ============================================================

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Replace this entire file with your generated hardware-configuration.nix
  # DO NOT nixos-rebuild switch until you've done this!
}
