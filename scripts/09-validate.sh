#!/usr/bin/env bash
set -euo pipefail

echo '==> Validando ferramentas instaladas'

test_bin() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    echo "[ok] $name -> $(command -v "$name")"
  else
    echo "[warn] $name não encontrado"
  fi
}

test_bin zsh
test_bin go
test_bin node
test_bin npm
test_bin python3
test_bin pip
test_bin docker
test_bin ollama
test_bin nvidia-smi

echo '==> Versões'
go version || true
node -v || true
npm -v || true
python3 --version || true
docker --version || true
ollama --version || true
nvidia-smi || true
