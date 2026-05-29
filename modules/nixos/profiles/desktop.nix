{ ... }:

{
  imports = [
    ../boot.nix
    ../networking.nix
    ../audio.nix
    ../bluetooth.nix
    ../fonts.nix
    ../flatpak.nix
    ../security.nix
    ../greetd.nix
    ../tailscale.nix
    ../mongodb.nix
    ../nix-ld.nix
  ];
}
