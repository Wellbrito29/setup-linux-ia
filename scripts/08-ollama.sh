#!/usr/bin/env bash
set -euo pipefail

if command -v ollama >/dev/null 2>&1; then
  echo '[skip] Ollama já está instalado'
  ollama --version || true
  exit 0
fi

echo '==> Instalando Ollama'
curl -fsSL https://ollama.com/install.sh | sh

echo '==> Validando instalação'
ollama --version || true

echo '==> Comandos úteis:'
echo '   ollama serve'
echo '   ollama list'
echo '   ollama run llama3.2'
echo '   ollama ps'
echo '==> Para aceitar conexões externas: OLLAMA_HOST=0.0.0.0 ollama serve'
