#!/usr/bin/env bash
set -euo pipefail

export NVM_DIR="$HOME/.nvm"

# Carrega NVM se já estiver instalado
# shellcheck disable=SC1090
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
fi

# Instala NVM apenas se nvm.sh existir e tiver conteúdo
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  echo '==> Instalando NVM'
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  # shellcheck disable=SC1090
  . "$NVM_DIR/nvm.sh"
else
  echo '[skip] NVM já instalado'
fi

# Garante que NVM está configurado no .zshrc
if [ -f "$HOME/.zshrc" ]; then
  grep -Fqx 'export NVM_DIR="$HOME/.nvm"' "$HOME/.zshrc" || {
    echo '' >> "$HOME/.zshrc"
    echo '# Node via NVM' >> "$HOME/.zshrc"
    echo 'export NVM_DIR="$HOME/.nvm"' >> "$HOME/.zshrc"
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$HOME/.zshrc"
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> "$HOME/.zshrc"
    echo '[ok] NVM adicionado ao .zshrc'
  }
fi

# Instala Node apenas se não estiver disponível
if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
  echo '[skip] Node e npm já instalados'
  node -v
  npm -v
  exit 0
fi

echo '==> Instalando Node LTS'
set +u
nvm install --lts
nvm use --lts
set -u

echo '==> Node instalado com sucesso'
node -v
npm -v
