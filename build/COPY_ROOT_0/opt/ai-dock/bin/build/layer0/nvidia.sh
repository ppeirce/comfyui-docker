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

build_nvidia_main() {
  build_nvidia_install_deps
  build_common_run_tests
  build_nvidia_run_tests
}

build_nvidia_install_deps() {
  short_cuda_version="cu$(cut -d '.' -f 1,2 <<<"${CUDA_VERSION}" | tr -d '.')"
  set_default_vision_audio_versions
  pkgs=("torch==${PYTORCH_VERSION}")
  [[ -n "${TORCHVISION_VERSION}" ]] && pkgs+=("torchvision==${TORCHVISION_VERSION}") || pkgs+=("torchvision")
  [[ -n "${TORCHAUDIO_VERSION}" ]] && pkgs+=("torchaudio==${TORCHAUDIO_VERSION}") || pkgs+=("torchaudio")

  "$COMFYUI_VENV_PIP" install --no-cache-dir \
    --index-url="https://download.pytorch.org/whl/${short_cuda_version}" \
    "${pkgs[@]}"

  if [[ -n "${XFORMERS_VERSION}" ]]; then
    "$COMFYUI_VENV_PIP" install --no-cache-dir "xformers==${XFORMERS_VERSION}"
  fi
}

build_nvidia_run_tests() {
  installed_cuda="$("$COMFYUI_VENV_PYTHON" -c 'import torch; print(torch.version.cuda or "")')"
  expected_cuda="$(cut -d '.' -f 1,2 <<<"${CUDA_VERSION}")"
  if [[ "$installed_cuda" != "$expected_cuda" ]]; then
    echo "Expected PyTorch CUDA ${expected_cuda} but found ${installed_cuda}"
    exit 1
  fi
}

build_nvidia_main "$@"
