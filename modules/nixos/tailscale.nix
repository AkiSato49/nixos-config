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

    # Persist Taildrive shares across reboots
    systemd.services.taildrive-shares = {
      description = "Register Taildrive shares";
      after = [ "tailscaled.service" "network-online.target" ];
      wants = [ "tailscaled.service" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "taildrive-share" ''
          ${pkgs.tailscale}/bin/tailscale drive share ${config.taildrive.shareName} /home/lawliet
        '';
        ExecStop = pkgs.writeShellScript "taildrive-unshare" ''
          ${pkgs.tailscale}/bin/tailscale drive unshare ${config.taildrive.shareName}
        '';
      };
    };

    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts   = [ config.services.tailscale.port ];
    };
  };
}
