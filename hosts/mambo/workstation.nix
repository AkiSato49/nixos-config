{ lib, pkgs, ... }:

{
  # Mambo-only workstation tuning. Keep laptop power and hardware policy isolated.
  hardware.alsa.enablePersistence = true;

  # Desktop has no WWAN modem. Keep laptop ModemManager policy untouched.
  networking.modemmanager.enable = lib.mkForce false;
  systemd.services.ModemManager.wantedBy = lib.mkForce [ ];

  # Docker/Immich tolerate network readiness themselves; avoid 5-6s boot wait.
  systemd.services.NetworkManager-wait-online.enable = false;

  # Reduce metadata writes on NVMe root. /srv already uses noatime + zstd.
  fileSystems."/".options = [ "noatime" ];

  # Keep CUDA context warm for faster Resolve startup on this always-on desktop.
  hardware.nvidia.nvidiaPersistenced = true;

  # Resolve can exceed 16 GiB during cache/render bursts. Compressed swap avoids
  # abrupt OOM kills without reserving disk space.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # LVFS only; updates remain manual. This never flashes firmware automatically.
  services.fwupd.enable = true;

  # No battery on mambo, but wireplumber + noctalia query UPower over dbus
  # (ServiceUnknown spam Sep 14). NixOS built-in service, no new dependency.
  services.upower.enable = true;

  # On-demand performance mode. Normal desktop use keeps amd-pstate EPP policy.
  programs.gamemode = {
    enable = true;
    settings.general = {
      desiredgov = "performance";
      softrealtime = "auto";
      renice = 10;
    };
  };

  # Remove stale Resolve retry-storm logs during normal tmpfiles cleanup.
  systemd.tmpfiles.rules = [
    "d /home/lawliet/.local/share/DaVinciResolve/logs 0755 lawliet users 14d"
  ];

  environment.systemPackages = with pkgs; [
    alsa-utils
    fwupd
    lm_sensors
    pavucontrol
    smartmontools
  ];
}
