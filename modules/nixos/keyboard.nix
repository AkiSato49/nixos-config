{ ... }:

{
  # Give logged-in user WebHID access to keyboards running Vial firmware.
  # Vial marks them with this serial prefix; rule does not expose other hidraw devices.
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';
}
