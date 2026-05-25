{ config, pkgs, ... }:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # Echo cancellation: creates a virtual mic with AEC + noise suppression + AGC.
    # Use "Echo-Cancel Source" in pavucontrol / wpctl as the input for dictation.
    extraConfig.pipewire."99-echo-cancel" = {
      "context.modules" = [
        {
          name = "libpipewire-module-echo-cancel";
          args = {
            "library.name"  = "aec/libspa-aec-webrtc";
            "node.latency"  = "1024/16000";
            "source.props" = {
              "node.name" = "echo-cancel-source";
              "node.description" = "Echo-Cancel Source";
            };
            "sink.props" = {
              "node.name" = "echo-cancel-sink";
              "node.description" = "Echo-Cancel Sink";
            };
            "monitor.mode" = false;
            "aec.args" = {
              "webrtc.gain_control"     = true;
              "webrtc.noise_suppression" = true;
              "webrtc.voice_detection"  = true;
              "webrtc.high_pass_filter" = true;
            };
          };
        }
      ];
    };
  };

  security.rtkit.enable = true;

  # Disable PulseAudio (replaced by PipeWire)
  services.pulseaudio.enable = false;
}
