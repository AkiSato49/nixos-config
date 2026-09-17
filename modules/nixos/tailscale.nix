{ config, pkgs, lib, ... }:

{
  options.taildrive.shareName = lib.mkOption {
    type = lib.types.str;
    default = config.networking.hostName;
    description = "Name for the Taildrive home share (default: hostname)";
  };

  config = {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };

    # gvfs: WebDAV backend so Nautilus can browse taildrive shares
    services.gvfs.enable = true;

    # Persist Taildrive shares across reboots.
    # Runs as lawliet -> shares owned by lawliet, not root.
    # tailscale(8): peers connect as local user; root share = wrong perms.
    systemd.services.taildrive-shares = {
      description = "Register Taildrive shares";
      after = [ "tailscaled.service" "network-online.target" ];
      wants = [ "tailscaled.service" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "lawliet";
        Restart = "on-failure";
        RestartSec = "30s";
        ExecStart = pkgs.writeShellScript "taildrive-share" ''
          set -euo pipefail
          # wait for tailscaled socket, max ~60s (boot race)
          for _ in $(seq 1 60); do
            ${pkgs.tailscale}/bin/tailscale status --peers=false >/dev/null 2>&1 && break
            sleep 1
          done
          ${pkgs.tailscale}/bin/tailscale drive share "${config.taildrive.shareName}" /home/lawliet
        '';
        ExecStop = pkgs.writeShellScript "taildrive-unshare" ''
          ${pkgs.tailscale}/bin/tailscale drive unshare "${config.taildrive.shareName}" || true
        '';
      };
    };

    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts   = [ config.services.tailscale.port ];
    };
  };
}
