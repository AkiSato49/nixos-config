{ config, pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };

  services.blueman.enable = true;

  # Intel AX200 BT shares USB with autosuspend=2s (btusb autosuspend=Y).
  # Suspended dongle stalls A2DP connects ("Device or resource busy") and
  # drops HFP gateway transport. Keep it powered; costs negligible idle power.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="8087", ATTR{idProduct}=="0029", ATTR{power/control}="on"
  '';

  # Pin headsets to A2DP on auto-connect. Default empty auto-connect lets
  # HFP/HSP race A2DP for the transport (Sep 14: a2dp-sink busy + HFP
  # endpoint 107 on Grado GW100x). HFP stays manually selectable for mic use.
  services.pipewire.wireplumber.extraConfig."55-bluez-a2dp" = {
    # Global: controls which A2DP endpoints PipeWire registers with BlueZ.
    # TEST Sep 14: cuts on aptX HD over AX200. Drop aptX pair, keep AAC+SBC.
    # Revert if cuts persist (then radio, not codec).
    "monitor.bluez.properties" = {
      "bluez5.codecs" = [ "aac" "sbc" "sbc_xq" ];
    };
    "monitor.bluez.rules" = [
      {
        matches = [ { "device.name" = "~bluez_card.*"; } ];
        actions = {
          "update-props" = {
            "bluez5.auto-connect" = [ "a2dp_sink" "a2dp_source" ];
            "bluez5.hw-volume" = [ "a2dp_sink" "a2dp_source" ];
          };
        };
      }
    ];
  };
}
