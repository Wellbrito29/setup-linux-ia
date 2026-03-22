#!/usr/bin/env bash
set -euo pipefail

echo '==> Instalando NVM'
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
else
  echo '==> NVM já está instalado'
fi

# shellcheck disable=SC1090
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

echo '==> Instalando Node LTS'
nvm install --lts
nvm use --lts

echo '==> Node instalado com sucesso'
node -v
npm -v
