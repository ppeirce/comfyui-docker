#!/bin/false

set_default_vision_audio_versions() {
  case "${PYTORCH_VERSION}" in
  2.4.0)
    TORCHVISION_VERSION="${TORCHVISION_VERSION:-0.19.0}"
    TORCHAUDIO_VERSION="${TORCHAUDIO_VERSION:-2.4.0}"
    ;;
  2.4.1)
    TORCHVISION_VERSION="${TORCHVISION_VERSION:-0.19.1}"
    TORCHAUDIO_VERSION="${TORCHAUDIO_VERSION:-2.4.1}"
    ;;
  2.5.1)
    TORCHVISION_VERSION="${TORCHVISION_VERSION:-0.20.1}"
    TORCHAUDIO_VERSION="${TORCHAUDIO_VERSION:-2.5.1}"
    ;;
  *) echo "Warning: no pinned defaults for PyTorch ${PYTORCH_VERSION}" ;;
  esac
}

build_cpu_main() {
  build_cpu_install_deps
  build_common_run_tests
}

build_cpu_install_deps() {
  if command -v nvidia-smi >/dev/null 2>&1; then
    echo "Detected NVIDIA GPU; aborting CPU-only torch install."
    exit 1
  fi
  set_default_vision_audio_versions
  pkgs=("torch==${PYTORCH_VERSION}")
  [[ -n "${TORCHVISION_VERSION}" ]] && pkgs+=("torchvision==${TORCHVISION_VERSION}") || pkgs+=("torchvision")
  [[ -n "${TORCHAUDIO_VERSION}" ]] && pkgs+=("torchaudio==${TORCHAUDIO_VERSION}") || pkgs+=("torchaudio")

  "$COMFYUI_VENV_PIP" install --no-cache-dir \
    --index-url=https://download.pytorch.org/whl/cpu \
    "${pkgs[@]}"
}

build_cpu_main "$@"

