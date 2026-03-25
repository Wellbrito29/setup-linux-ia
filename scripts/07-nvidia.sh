#!/usr/bin/env bash
set -euo pipefail

if command -v nvidia-smi >/dev/null 2>&1; then
  echo '[skip] Driver NVIDIA já instalado'
  nvidia-smi
  exit 0
fi

echo '==> Verificando drivers NVIDIA disponíveis'
sudo apt update
sudo apt install -y ubuntu-drivers-common
ubuntu-drivers devices || true

echo '==> Instalando driver recomendado'
sudo ubuntu-drivers install

echo '==> Instalação concluída. Reinicie a máquina e rode: nvidia-smi'
