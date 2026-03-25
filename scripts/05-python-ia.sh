#!/usr/bin/env bash
set -euo pipefail

VENV_DIR="${VENV_DIR:-$HOME/venvs/ia}"
PYTHON_BIN="$VENV_DIR/bin/python"
PIP_BIN="$VENV_DIR/bin/pip"

mkdir -p "$(dirname "$VENV_DIR")"

# Instala python3-venv via apt só se não estiver disponível
if ! python3 -m venv --help >/dev/null 2>&1; then
  echo '==> Instalando python3-venv'
  sudo apt -o DPkg::Lock::Timeout=120 install -y python3-venv
fi

if [[ -d "$VENV_DIR" ]]; then
  echo "[skip] Venv já existe em $VENV_DIR"
else
  python3 -m venv "$VENV_DIR"
fi

# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"

if "$PYTHON_BIN" - <<'PY'
import importlib.util
import sys

mods = [
    'jupyterlab',
    'numpy',
    'pandas',
    'scipy',
    'matplotlib',
    'sklearn',
    'transformers',
    'datasets',
    'accelerate',
    'sentencepiece',
    'cv2',
    'PIL',
    'ipykernel',
]
sys.exit(0 if all(importlib.util.find_spec(m) for m in mods) else 1)
PY
then
  echo '[skip] Pacotes principais de IA já estão instalados no venv'
else
  "$PIP_BIN" install --upgrade pip setuptools wheel
  "$PIP_BIN" install \
  jupyterlab \
  numpy pandas scipy matplotlib scikit-learn \
  transformers datasets accelerate sentencepiece \
  opencv-python pillow \
  ipykernel
fi

"$PYTHON_BIN" -m ipykernel install --user --name ubuntu-ia --display-name "Python (ubuntu-ia)"

echo '==> Ambiente Python para IA pronto'
echo "==> Ative com: source $VENV_DIR/bin/activate"
