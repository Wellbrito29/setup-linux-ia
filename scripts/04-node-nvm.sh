#!/usr/bin/env bash
set -euo pipefail

export NVM_DIR="$HOME/.nvm"

# Carrega NVM se já estiver instalado
# shellcheck disable=SC1090
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Instala NVM apenas se o diretório não existir
if [ ! -d "$NVM_DIR" ]; then
  echo '==> Instalando NVM'
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  # shellcheck disable=SC1090
  . "$NVM_DIR/nvm.sh"
else
  echo '[skip] NVM já instalado'
fi

# Instala Node apenas se não estiver disponível
if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
  echo '[skip] Node e npm já instalados'
  node -v
  npm -v
  exit 0
fi

echo '==> Instalando Node LTS'
nvm install --lts
nvm use --lts

echo '==> Node instalado com sucesso'
node -v
npm -v
