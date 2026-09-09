{ pkgs, ... }:

{
  # Add udev rules for MTP devices
  services.udev.packages = [ pkgs.libmtp ];

  # Allow non-root FUSE mounts (allows other users to access mounted camera directories)
  programs.fuse.userAllowOther = true;

  # Enable Udisks2 for block device volume management
  services.udisks2.enable = true;

  # Enable GVFS for automounting via file managers (Nautilus, Thunar, etc.)
  services.gvfs.enable = true;

  # CLI and FUSE packages for PTP and MTP photography workflows
  environment.systemPackages = with pkgs; [
    gphoto2       # CLI tool for PTP camera backup & control
    gphoto2fs     # FUSE driver for mounting PTP cameras
    simple-mtpfs  # FUSE driver for mounting MTP cameras
    jmtpfs        # Alternative MTP FUSE driver
  ];
}
