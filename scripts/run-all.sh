#!/usr/bin/env bash
set -euo pipefail

echo '==> Rodando setup completo'

./scripts/00-system-update.sh
./scripts/01-dev-base.sh
./scripts/02-zsh-ohmyzsh.sh
./scripts/03-go.sh
./scripts/04-node-nvm.sh
./scripts/05-python-ia.sh
./scripts/06-docker.sh
./scripts/07-nvidia.sh
./scripts/08-ollama.sh
./scripts/09-validate.sh

echo '==> Setup concluído'
