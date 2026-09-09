{ config, pkgs, ... }:

{
  hardware.enableAllFirmware = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber = {
      enable = true;
      extraConfig."51-disable-hdmi" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "node.name" = "~alsa_output.pci-.*HDMI.*"; }
            ];
            actions = {
              "update-props" = {
                "node.disabled" = true;
              };
            };
          }
          {
            matches = [
              { "device.name" = "~alsa_card.pci-.*"; }
            ];
            actions = {
              "update-props" = {
                "api.alsa.use-acp" = true;
                "api.alsa.use-ucm" = true;
              };
            };
          }
        ];
      };
      extraConfig."52-force-hifi-profile" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "device.name" = "~alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic"; }
            ];
            actions = {
              "update-props" = {
                "api.acp.auto-profile" = true;
                "api.acp.auto-port" = true;
              };
            };
          }
        ];
      };
    };
  };

  security.rtkit.enable = true;

  # Disable PulseAudio (replaced by PipeWire)
  services.pulseaudio.enable = false;
}
