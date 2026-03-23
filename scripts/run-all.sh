#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo '==> Rodando setup completo'

"$SCRIPT_DIR/00-system-update.sh"
"$SCRIPT_DIR/01-dev-base.sh"
"$SCRIPT_DIR/02-zsh-ohmyzsh.sh"
"$SCRIPT_DIR/03-go.sh"
"$SCRIPT_DIR/04-node-nvm.sh"
"$SCRIPT_DIR/05-python-ia.sh"
"$SCRIPT_DIR/06-docker.sh"
"$SCRIPT_DIR/07-nvidia.sh"
"$SCRIPT_DIR/08-ollama.sh"
"$SCRIPT_DIR/10-vscode.sh"
"$SCRIPT_DIR/11-nvidia-container-toolkit.sh"
"$SCRIPT_DIR/12-pytorch-gpu-test.sh"
"$SCRIPT_DIR/09-validate.sh"

echo '==> Setup concluído'
