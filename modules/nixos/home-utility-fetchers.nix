{ config, pkgs, lib, ... }:

let
  # Path where the project lives on mambo
  projectDir = "/home/lawliet/Projects/home-utility-fetchers";
in
{
  # Chromium for Playwright
  environment.systemPackages = [ pkgs.chromium ];

  # Cron job: check all bills daily at 8am Sydney time
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 8 * * * lawliet cd ${projectDir} && /run/current-system/sw/bin/env CHROMIUM_PATH=${pkgs.chromium}/bin/chromium npx tsx src/runner.ts >> /var/log/home-utility-fetchers.log 2>&1"
    ];
  };

  # Log file
  systemd.tmpfiles.rules = [
    "f /var/log/home-utility-fetchers.log 0644 lawliet users -"
  ];
}
