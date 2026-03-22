#!/usr/bin/env bash
set -euo pipefail

VENV_DIR="${VENV_DIR:-$HOME/venvs/ia}"

if [ ! -d "$VENV_DIR" ]; then
  echo '[skip] Venv não encontrado. Rode primeiro scripts/05-python-ia.sh'
  exit 0
fi

# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"

if python - <<'PY'
import importlib.util
import sys
sys.exit(0 if importlib.util.find_spec('torch') else 1)
PY
then
  echo '[skip] PyTorch já está instalado no venv'
else
  echo '==> Instalando PyTorch'
  pip install torch torchvision torchaudio
fi

echo '==> Testando GPU com PyTorch'
python - <<'PY'
import torch
print('torch version:', torch.__version__)
print('cuda available:', torch.cuda.is_available())
if torch.cuda.is_available():
    print('device count:', torch.cuda.device_count())
    print('device name:', torch.cuda.get_device_name(0))
PY
