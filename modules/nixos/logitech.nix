{ ... }:

{
  # Solaar communicates with Logitech Bolt receivers through hidraw.
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c548", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';
}
