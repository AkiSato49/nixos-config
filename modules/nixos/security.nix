{ config, pkgs, ... }:

{
  # 1Password
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "lawliet" ];
  };

  # Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # Disk health monitoring
  services.smartd.enable = true;

  # Keyring
  services.gnome.gnome-keyring.enable = true;

  # Fingerprint
  services.fprintd.enable = true;
  security.pam.services = {
    login.fprintAuth     = true;
    sudo.fprintAuth      = true;
    hyprlock.fprintAuth  = true;
  };
}
