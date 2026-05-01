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
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "net.reactivated.fprint.device.enroll" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';
  security.pam.services = {
    login.fprintAuth    = true;
    sudo.fprintAuth     = true;
    greetd.fprintAuth   = true;

    # Hyprlock: fingerprint with 5s timeout, then fall back to password
    hyprlock.text = ''
      auth sufficient pam_fprintd.so timeout=5
      auth sufficient pam_unix.so likeauth try_first_pass
      auth required  pam_deny.so

      account required pam_unix.so
      password sufficient pam_unix.so nullok yescrypt
      session required pam_unix.so
    '';
  };
}
