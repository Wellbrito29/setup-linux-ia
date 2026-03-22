#!/usr/bin/env bash
set -euo pipefail

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
