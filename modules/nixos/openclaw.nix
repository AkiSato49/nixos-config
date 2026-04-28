{ config, pkgs, lib, ... }:

{
  # Install Node.js + mise for openclaw runtime
  environment.systemPackages = with pkgs; [
    nodejs_22
    mise
  ];

  # OpenClaw gateway as a systemd user service
  systemd.user.services.openclaw = {
    description = "OpenClaw Gateway";
    after = [ "network-online.target" "tailscaled.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "default.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.nodejs_22}/bin/node %h/.local/share/mise/installs/node/25.2.1/lib/node_modules/openclaw/bin/openclaw.js gateway start";
      Restart = "on-failure";
      RestartSec = "5s";
      # Config lives at ~/.openclaw/openclaw.json — drop it in manually post-install
    };
  };
}
