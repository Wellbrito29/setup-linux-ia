#!/usr/bin/env bash
set -euo pipefail

echo '==> Atualizando sistema'
sudo apt update && sudo apt upgrade -y

echo '==> Sistema atualizado com sucesso'
