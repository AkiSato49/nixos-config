{ ... }:
{
  fileSystems."/srv" = {
    device = "/dev/disk/by-uuid/778bc0cf-c989-4854-800b-456a59ad191b";
    fsType = "btrfs";
    options = [ "subvol=@srv" "compress=zstd" "noatime" ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/immich 0755 lawliet users -"
  ];
}
