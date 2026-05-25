{ pkgs, ... }:

let
  # Python env with openvino (from nixpkgs) for the venv base
  pythonWithOpenvino = pkgs.python3.withPackages (ps: with ps; [
    openvino
    pip
  ]);

  # NPU-accelerated Whisper via OpenVINO GenAI
  # First run: creates a venv, pip-installs optimum-intel + openvino-genai,
  #            and converts the model to OpenVINO IR format (takes a few minutes).
  # Subsequent runs: loads the cached model and transcribes on NPU.
  whisper-npu = pkgs.writeShellScriptBin "whisper-npu" ''
    set -euo pipefail

    WHISPER_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/whisper-npu"
    VENV="$WHISPER_DIR/venv"
    MODEL_STORE="$WHISPER_DIR/models"
    MODEL_SIZE="''${WHISPER_MODEL:-small}"
    AUDIO_FILE="''${1:-}"
    DEVICE="''${WHISPER_DEVICE:-NPU}"

    usage() {
      echo "Usage: whisper-npu <audio-file>"
      echo ""
      echo "Env vars:"
      echo "  WHISPER_MODEL   Model size: tiny | base | small | medium (default: small)"
      echo "  WHISPER_DEVICE  Device: NPU | CPU | GPU (default: NPU)"
      exit 0
    }

    [ -z "$AUDIO_FILE" ] && usage
    [ "$AUDIO_FILE" = "--help" ] && usage

    # ── 1. Bootstrap venv ──────────────────────────────────────────────────────
    if [ ! -f "$VENV/bin/python" ]; then
      echo "[whisper-npu] First run: setting up environment..."
      mkdir -p "$WHISPER_DIR"
      ${pythonWithOpenvino}/bin/python -m venv --system-site-packages "$VENV"
      "$VENV/bin/pip" install --quiet --upgrade pip
      "$VENV/bin/pip" install --quiet \
        "openvino-genai==2026.1.0" \
        "openvino-tokenizers==2026.1.0" \
        "optimum-intel>=1.22" \
        "transformers>=4.45" \
        "soundfile" \
        "librosa"
      echo "[whisper-npu] Environment ready."
    fi

    # ── 2. Convert model (once per model size) ─────────────────────────────────
    OV_MODEL="$MODEL_STORE/whisper-$MODEL_SIZE-int8"
    if [ ! -d "$OV_MODEL" ]; then
      echo "[whisper-npu] Converting whisper-$MODEL_SIZE → OpenVINO IR int8 (one-time, ~2 min)..."
      mkdir -p "$MODEL_STORE"
      "$VENV/bin/optimum-cli" export openvino \
        --model "openai/whisper-$MODEL_SIZE" \
        --task automatic-speech-recognition-with-past \
        --weight-format int8 \
        "$OV_MODEL"
      echo "[whisper-npu] Model saved to $OV_MODEL"
    fi

    # ── 3. Transcribe ──────────────────────────────────────────────────────────
    echo "[whisper-npu] Transcribing on $DEVICE..."
    OV_MODEL="$OV_MODEL" AUDIO_FILE="$AUDIO_FILE" DEVICE="$DEVICE" \
    "$VENV/bin/python" - <<'PYEOF'
import os, sys
import numpy as np
import soundfile as sf
import librosa
import openvino_genai as ov_genai

model_dir  = os.environ["OV_MODEL"]
audio_file = os.environ["AUDIO_FILE"]
device     = os.environ["DEVICE"]

# Load + resample to 16 kHz mono (Whisper requirement)
audio, sr = librosa.load(audio_file, sr=16000, mono=True)
audio = audio.astype(np.float32)

pipe = ov_genai.WhisperPipeline(model_dir, device)
result = pipe.generate(audio)
print(result)
PYEOF
  '';

in
{
  home.packages = with pkgs; [
    openai-whisper   # standard CPU whisper CLI: `whisper audio.mp3 --model small`
    whisper-npu      # NPU-accelerated: `whisper-npu audio.mp3`
    ffmpeg           # audio decoding / format conversion
  ];
}
