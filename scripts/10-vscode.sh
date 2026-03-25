#!/usr/bin/env bash
set -euo pipefail

if command -v code >/dev/null 2>&1; then
  echo '[skip] VS Code já está instalado'
  code --version || true
  exit 0
fi

echo '==> Instalando dependências do VS Code'
sudo apt -o DPkg::Lock::Timeout=120 update
sudo apt -o DPkg::Lock::Timeout=120 install -y wget gpg apt-transport-https

if [ ! -f /etc/apt/keyrings/packages.microsoft.gpg ]; then
  sudo install -d -m 0755 /etc/apt/keyrings
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg >/dev/null
  sudo chmod go+r /etc/apt/keyrings/packages.microsoft.gpg
fi

if [ ! -f /etc/apt/sources.list.d/vscode.sources ]; then
  echo 'Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64 arm64 armhf
Signed-By: /etc/apt/keyrings/packages.microsoft.gpg' | sudo tee /etc/apt/sources.list.d/vscode.sources >/dev/null
fi

sudo apt -o DPkg::Lock::Timeout=120 update
sudo apt -o DPkg::Lock::Timeout=120 install -y code

echo '==> VS Code instalado com sucesso'
code --version || true
