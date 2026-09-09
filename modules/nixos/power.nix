{ pkgs, ... }:

{
  # X1 Carbon Gen 13 exposes low-power, balanced, and performance through
  # thinkpad_acpi. power-profiles-daemon drives those firmware profiles and
  # backs the three mode buttons in the Waybar battery popup.
  services.auto-cpufreq.enable = false;
  services.power-profiles-daemon.enable = true;

  # Start conservatively after every boot. Manual profile changes remain in
  # effect until reboot and can be made from the Waybar battery popup.
  systemd.services.default-power-profile = {
    description = "Select battery-saving power profile";
    after = [ "power-profiles-daemon.service" ];
    requires = [ "power-profiles-daemon.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver";
    };
  };

  powerManagement.enable = true;

  # Battery popup data plus safe low-battery hibernation.
  services.upower = {
    enable = true;
    usePercentageForPolicy = true;
    percentageLow = 20;
    percentageCritical = 8;
    percentageAction = 5;
    criticalPowerAction = "Hibernate";
  };

  # Kernel targets a ~12 GiB hibernation image on this 32 GiB machine.
  # 16 GiB leaves headroom without reserving RAM-sized disk space.
  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
    }
  ];

  # s2idle gives fast short-term wake, then hibernation stops long-term drain.
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "30m";
    HibernateOnACPower = true;
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
  };
}
