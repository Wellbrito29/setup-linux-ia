#!/usr/bin/env bash
set -euo pipefail

echo '==> Atualizando lista de pacotes'
sudo apt -o DPkg::Lock::Timeout=120 update

read -r -p 'Atualizar pacotes do sistema agora? [s/N] ' confirm </dev/tty || true
if [[ "${confirm,,}" == 's' ]]; then
  echo '==> Atualizando pacotes'
  sudo apt -o DPkg::Lock::Timeout=120 upgrade -y
  echo '==> Sistema atualizado com sucesso'
else
  echo '[skip] Upgrade do sistema pulado'
fi
