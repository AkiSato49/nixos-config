{ config, pkgs, ... }:

{
  # 1Password
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "lawliet" ];
  };
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      zen
    '';
    mode = "0755";
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

  # Polkit authentication UI
  security.soteria.enable = true;

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
    login.enableGnomeKeyring = true;
    greetd.enableGnomeKeyring = true;
    login.fprintAuth    = true;
    sudo.fprintAuth     = true;
    greetd.fprintAuth   = true;
    onepassword.fprintAuth = true;

    # Noctalia uses PAM's `login` service. Default pam_fprintd timeout is
    # 30 seconds, which leaves its lockscreen stuck on "Authenticating"
    # before password fallback. Keep fingerprint unlock, but fail over fast.
    login.rules.auth.fprintd.settings.timeout = 5;

    # Noctalia Greeter authenticates through PAM's `greetd` service at boot.
    # Give it same bounded fingerprint attempt before password fallback.
    greetd.rules.auth.fprintd.settings.timeout = 5;

    # Hyprlock: fingerprint with 5s timeout, then fall back to password
    hyprlock.text = ''
      auth sufficient pam_fprintd.so timeout=5
      auth sufficient pam_unix.so likeauth try_first_pass
      auth required  pam_deny.so

      account required pam_unix.so
      password sufficient pam_unix.so nullok yescrypt
      session required pam_unix.so
    '';

    # GTKLock is explicit recovery lock. Match other lock PAM services so a
    # missed scan reaches password fallback quickly instead of appearing hung.
    gtklock.text = ''
      auth sufficient pam_fprintd.so max-tries=3 timeout=5
      auth sufficient pam_unix.so likeauth try_first_pass
      auth required  pam_deny.so

      account required pam_unix.so
      password sufficient pam_unix.so nullok yescrypt
      session required pam_unix.so
    '';
  };
}
