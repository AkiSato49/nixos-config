{ config, lib, pkgs, ... }:

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
      # Resolve's Fairlight engine continuously reconnects unless both input
      # and output exist under one stable Pro Audio profile.
      extraConfig."53-mambo-resolve-audio" = lib.mkIf (config.networking.hostName == "mambo") {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "device.name" = "alsa_card.pci-0000_0d_00.4"; }
            ];
            actions."update-props" = {
              "device.profile" = "pro-audio";
              "api.acp.auto-profile" = false;
            };
          }
          {
            # ALC887 optical/SPDIF output (hw:1,1).
            matches = [
              { "node.name" = "alsa_output.pci-0000_0d_00.4.pro-output-1"; }
            ];
            actions."update-props"."priority.session" = 3000;
          }
          {
            # ALC887 analog capture (hw:1,0); Fairlight requires an input even
            # for playback-only sessions.
            matches = [
              { "node.name" = "alsa_input.pci-0000_0d_00.4.pro-input-0"; }
            ];
            actions."update-props"."priority.session" = 3000;
          }
        ];
      };
    };
  };

  security.rtkit.enable = true;

  # Disable PulseAudio (replaced by PipeWire)
  services.pulseaudio.enable = false;
}
