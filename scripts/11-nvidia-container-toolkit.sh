#!/usr/bin/env bash
set -euo pipefail

if ! command -v nvidia-smi >/dev/null 2>&1; then
  echo '[skip] NVIDIA driver não encontrado. Instale e valide nvidia-smi antes do toolkit.'
  exit 0
fi

if dpkg -s nvidia-container-toolkit >/dev/null 2>&1; then
  echo '[skip] NVIDIA Container Toolkit já está instalado'
  exit 0
fi

echo '==> Instalando NVIDIA Container Toolkit'
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list >/dev/null
sudo apt -o DPkg::Lock::Timeout=120 update
sudo apt -o DPkg::Lock::Timeout=120 install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

echo '==> Toolkit instalado. Teste sugerido:'
echo 'docker run --rm --gpus all ubuntu nvidia-smi'
