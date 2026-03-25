#!/usr/bin/env bash
set -euo pipefail

if command -v docker >/dev/null 2>&1; then
  echo '[skip] Docker já está instalado'
  docker --version
  exit 0
fi

echo '==> Instalando Docker'
sudo apt update
sudo apt install -y docker.io docker-compose-v2
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker "$USER"

echo '==> Docker instalado com sucesso'
docker --version || true
echo '==> Talvez seja necessário fazer logout/login para usar Docker sem sudo'
