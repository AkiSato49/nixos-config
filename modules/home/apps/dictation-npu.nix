{ pkgs, config, lib, ... }:

# NPU dictation — toggle with SUPER+D.
#
# Architecture:
#   whisper-npu-daemon (systemd user service)
#     → keeps WhisperPipeline loaded in memory, listens on Unix socket
#     → zero pipeline load time after first NPU compile
#
#   dictate-npu-toggle
#     → if not recording: start pw-record, notify
#     → if recording:     stop pw-record, send WAV to daemon, type result
#
# Model: OpenVINO/whisper-small.en-int8-ov  (English-only, more accurate)

let
  whisperDir = "${config.xdg.dataHome}/whisper-npu";
  venv       = "${whisperDir}/venv";
  modelDir   = "${whisperDir}/models/whisper-small.en-int8-ov";
  cacheDir   = "${config.xdg.cacheHome}/whisper-npu";
  sockPath   = "/tmp/whisper-npu-daemon.sock";
  pidFile    = "/tmp/dictate-npu.pid";
  wavFile    = "/tmp/dictate-npu.wav";

  pythonWithOpenvino = pkgs.python3.withPackages (ps: with ps; [ openvino pip ]);

  # Python socket client — written as a file to avoid shell quoting hell
  socketClient = pkgs.writeText "whisper-npu-client.py" ''
    import socket, sys, os
    sock_path = sys.argv[1]
    wav_path  = sys.argv[2]
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    try:
        s.connect(sock_path)
        s.sendall((wav_path + "\n").encode())
        s.shutdown(socket.SHUT_WR)
        data = b""
        while True:
            chunk = s.recv(4096)
            if not chunk:
                break
            data += chunk
        s.close()
        sys.stdout.write(data.decode())
    except Exception as e:
        sys.exit(0)
  '';

  # Wrapper that injects all required env vars for NPU + pip openvino
  npu-env = pkgs.writeShellScriptBin "npu-env" ''
    export ZE_ENABLE_ALT_DRIVERS=/run/opengl-driver/lib/libze_intel_npu.so
    export LD_LIBRARY_PATH="\
    ${pkgs.level-zero}/lib:\
    ${pkgs.stdenv.cc.cc.lib}/lib:\
    ${pkgs.zlib}/lib:\
    ${pkgs.zstd}/lib:\
    ${pkgs.tbb}/lib:\
    /run/opengl-driver/lib:\
    ''${LD_LIBRARY_PATH:-}"
    exec "$@"
  '';

  # Background daemon — loads the pipeline once, serves transcriptions over a socket
  whisper-npu-daemon = pkgs.writeShellScriptBin "whisper-npu-daemon" ''
    set -euo pipefail

    # Bootstrap venv if needed
    if [ ! -f "${venv}/bin/python" ]; then
      mkdir -p "${whisperDir}"
      ${pythonWithOpenvino}/bin/python -m venv --system-site-packages "${venv}"
      "${venv}/bin/pip" install --quiet --upgrade pip
      "${venv}/bin/pip" install --quiet \
        "openvino==2025.4.0" \
        "openvino-genai==2025.4.0.0" \
        "openvino-tokenizers==2025.4.0.0" \
        "soundfile" "librosa" "huggingface_hub"
    fi

    # Download model if needed
    if [ ! -f "${modelDir}/openvino_encoder_model.xml" ]; then
      mkdir -p "${modelDir}"
      export MODEL_DIR="${modelDir}"
      ${npu-env}/bin/npu-env "${venv}/bin/python" -c "
import os
from huggingface_hub import snapshot_download
snapshot_download('OpenVINO/whisper-small.en-int8-ov', local_dir=os.environ['MODEL_DIR'])
"
    fi

    mkdir -p "${cacheDir}"
    rm -f "${sockPath}"

    exec ${npu-env}/bin/npu-env "${venv}/bin/python" - <<'PYEOF'
import socket, os, sys, numpy as np, librosa, openvino_genai as ov_genai

SOCK   = "${sockPath}"
MODEL  = "${modelDir}"
CACHE  = "${cacheDir}"

print("Loading WhisperPipeline on NPU...", flush=True)
pipe = ov_genai.WhisperPipeline(MODEL, "NPU", config={"CACHE_DIR": CACHE})
print("Pipeline ready.", flush=True)

server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
server.bind(SOCK)
os.chmod(SOCK, 0o600)
server.listen(1)

while True:
    conn, _ = server.accept()
    try:
        wav = conn.recv(4096).decode().strip()
        text = ""
        if wav and os.path.exists(wav):
            audio, _ = librosa.load(wav, sr=16000, mono=True)
            # Skip near-silent audio (avoid hallucination)
            if np.sqrt(np.mean(audio**2)) >= 0.005:
                config = ov_genai.WhisperGenerationConfig()
                config.max_new_tokens = 128
                config.no_repeat_ngram_size = 3
                result = pipe.generate(audio.astype(np.float32), config)
                text = str(result).strip()
        try:
            conn.sendall(text.encode())
        except BrokenPipeError:
            pass
    except Exception as e:
        print(f"error: {e}", file=sys.stderr, flush=True)
        try:
            conn.sendall(b"")
        except Exception:
            pass
    finally:
        try:
            conn.close()
        except Exception:
            pass
PYEOF
  '';

  # Toggle: one press starts recording, another press stops + transcribes
  dictate-npu-toggle = pkgs.writeShellScriptBin "dictate-npu-toggle" ''
    set -euo pipefail

    if [ -f "${pidFile}" ]; then
      # ── STOP ──────────────────────────────────────────────────────────
      PID=$(cat "${pidFile}")
      kill "$PID" 2>/dev/null || true
      while kill -0 "$PID" 2>/dev/null; do sleep 0.05; done
      rm -f "${pidFile}"

      [ ! -s "${wavFile}" ] && exit 0

      ${pkgs.libnotify}/bin/notify-send \
        -u low -t 5000 \
        -h string:x-canonical-private-synchronous:dictate-npu \
        "🧠 Transcribing on NPU..."

      # Send wav path to daemon via Python script file (avoids shell quoting issues)
      TEXT=$(${npu-env}/bin/npu-env \
        "${venv}/bin/python" "${socketClient}" \
        "${sockPath}" "${wavFile}" 2>/dev/null || echo "")

      rm -f "${wavFile}"

      if [ -n "$TEXT" ]; then
        ${pkgs.libnotify}/bin/notify-send -u low -t 3000 "✅ NPU" "$TEXT"
        printf '%s' "$TEXT" | ${pkgs.wtype}/bin/wtype -
      else
        ${pkgs.libnotify}/bin/notify-send -u low -t 2000 "⚠️ Nothing detected"
      fi

    else
      # ── START ─────────────────────────────────────────────────────────
      # Ensure daemon is running
      if ! test -S "${sockPath}"; then
        systemctl --user start whisper-npu-daemon.service 2>/dev/null || true
        # Brief wait for daemon socket
        for i in $(seq 1 20); do
          test -S "${sockPath}" && break
          sleep 0.5
        done
      fi

      ${pkgs.libnotify}/bin/notify-send \
        -u low -t 60000 \
        -h string:x-canonical-private-synchronous:dictate-npu \
        "🎙️ Recording... (press Super+D again to stop)"

      ${pkgs.pipewire}/bin/pw-record \
        --rate 16000 --channels 1 --format s16 \
        --container wav \
        --target echo-cancel-source \
        "${wavFile}" &
      echo $! > "${pidFile}"
    fi
  '';

in
{
  home.packages = [ npu-env whisper-npu-daemon dictate-npu-toggle pkgs.socat pkgs.libnotify ];

  # Daemon — loads the NPU pipeline once at login, stays hot in memory
  systemd.user.services.whisper-npu-daemon = {
    Unit = {
      Description = "Whisper NPU transcription daemon";
      After = [ "default.target" ];
    };
    Service = {
      Type       = "simple";
      ExecStart  = "${whisper-npu-daemon}/bin/whisper-npu-daemon";
      Restart    = "on-failure";
      RestartSec = "5s";
    };
    Install.WantedBy = [ "default.target" ];
  };

  # NPU toggle — Super+Shift+D (CPU version owns Super+D for now)
  wayland.windowManager.hyprland.extraConfig = ''
    bind  = SUPER SHIFT, D, exec, dictate-npu-toggle
  '';
}
