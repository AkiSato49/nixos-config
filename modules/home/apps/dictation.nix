{ pkgs, config, lib, ... }:

let
  dataDir    = "${config.xdg.dataHome}/whisper-dictation";
  serverPort = 2224;
  serverUrl  = "http://127.0.0.1:${toString serverPort}";
  pidFile    = "/tmp/dictate.pid";
  wavFile    = "/tmp/dictate.wav";

  # Default model — small.en is a good CPU sweet spot.
  # For better accuracy (slower): set WHISPER_MODEL=large-v3-turbo-q5_0
  # and it will be downloaded on first server start.
  defaultModel = "small.en";

  # Wrapper that downloads the model if missing, then starts whisper-server.
  # Runs as the systemd service ExecStart.
  whisper-server-launcher = pkgs.writeShellScriptBin "whisper-server-launcher" ''
    set -euo pipefail
    MODEL_NAME="''${WHISPER_MODEL:-${defaultModel}}"
    MODEL_PATH="${dataDir}/ggml-$MODEL_NAME.bin"

    if [ ! -f "$MODEL_PATH" ]; then
      mkdir -p "${dataDir}"
      echo "whisper-server: downloading $MODEL_NAME..." >&2
      ${pkgs.whisper-cpp}/bin/whisper-cpp-download-ggml-model \
        "$MODEL_NAME" "${dataDir}"
    fi

    exec ${pkgs.whisper-cpp}/bin/whisper-server \
      --model  "$MODEL_PATH" \
      --host   127.0.0.1 \
      --port   ${toString serverPort} \
      --threads $(nproc) \
      --inference-path /v1/audio/transcriptions
  '';

  dictate-start = pkgs.writeShellScriptBin "dictate-start" ''
    # Already recording — ignore
    [ -f "${pidFile}" ] && exit 0

    # Warn if server isn't up yet
    if ! ${pkgs.curl}/bin/curl -sf --max-time 0.5 \
        "${serverUrl}/health" >/dev/null 2>&1; then
      ${pkgs.libnotify}/bin/notify-send -u low -t 2000 \
        "⚠️ Whisper server" "Starting up, try again in a moment"
      systemctl --user start whisper-dictation.service 2>/dev/null || true
      exit 0
    fi

    ${pkgs.libnotify}/bin/notify-send \
      -u low -t 60000 \
      -h string:x-canonical-private-synchronous:dictate \
      "🎙️ Recording..." "Release Super+D to transcribe"

    ${pkgs.pipewire}/bin/pw-record \
      --rate 16000 --channels 1 --format s16 \
      --container wav \
      --target echo-cancel-source \
      "${wavFile}" &
    echo $! > "${pidFile}"
  '';

  dictate-stop = pkgs.writeShellScriptBin "dictate-stop" ''
    set -euo pipefail

    # Stop recording, wait for pw-record to flush + close the WAV
    if [ -f "${pidFile}" ]; then
      PID=$(cat "${pidFile}")
      kill "$PID" 2>/dev/null || true
      while kill -0 "$PID" 2>/dev/null; do sleep 0.05; done
      rm -f "${pidFile}"
    fi

    [ ! -s "${wavFile}" ] && exit 0

    ${pkgs.libnotify}/bin/notify-send \
      -u low -t 3000 \
      -h string:x-canonical-private-synchronous:dictate \
      "🧠 Transcribing..."

    # POST audio to the local whisper-server (model already hot in RAM)
    TEXT=$(${pkgs.curl}/bin/curl -sf --max-time 30 \
      "${serverUrl}/v1/audio/transcriptions" \
      -F "file=@${wavFile};type=audio/wav" \
      -F "response_format=text" \
      -F "language=en" \
      2>/dev/null | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    rm -f "${wavFile}"

    if [ -n "$TEXT" ]; then
      ${pkgs.libnotify}/bin/notify-send -u low -t 3000 "✅ Typed" "$TEXT"
      printf '%s' "$TEXT" | ${pkgs.wtype}/bin/wtype -
    else
      ${pkgs.libnotify}/bin/notify-send -u low -t 2000 "⚠️ Nothing detected"
    fi
  '';

in
{
  home.packages = with pkgs; [
    dictate-start
    dictate-stop
    whisper-server-launcher
    whisper-cpp
    libnotify
  ];

  # First Super+D press starts Whisper on demand; second press records once
  # model is ready. Stop after 30 minutes so it does not occupy battery sessions.
  systemd.user.services.whisper-dictation = {
    Unit.Description = "Whisper.cpp local transcription server";
    Service = {
      Type = "simple";
      ExecStart = "${whisper-server-launcher}/bin/whisper-server-launcher";
      RuntimeMaxSec = "30m";
      Environment = [
        "WHISPER_MODEL=${defaultModel}"
      ];
    };
  };

  # CPU push-to-talk: hold Super+D to record, release to transcribe + type
  wayland.windowManager.hyprland.extraConfig = ''
    bind  = SUPER, D, exec, dictate-start
    bindr = SUPER, D, exec, dictate-stop
  '';
}
