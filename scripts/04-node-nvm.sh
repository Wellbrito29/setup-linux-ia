#!/usr/bin/env bash
set -euo pipefail

if command -v nvm >/dev/null 2>&1; then
  echo '[skip] NVM já está disponível no shell atual'
else
  export NVM_DIR="$HOME/.nvm"
  if [ ! -d "$NVM_DIR" ]; then
    echo '==> Instalando NVM'
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  else
    echo '[skip] Diretório do NVM já existe'
  fi
  # shellcheck disable=SC1090
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
fi

if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
  echo '[skip] Node e npm já estão instalados'
  node -v || true
  npm -v || true
  exit 0
fi

echo '==> Instalando Node LTS'
nvm install --lts
nvm use --lts

echo '==> Node instalado com sucesso'
node -v
npm -v
