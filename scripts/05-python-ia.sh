#!/usr/bin/env bash
set -euo pipefail

VENV_DIR="${VENV_DIR:-$HOME/venvs/ia}"

echo '==> Instalando Python e criando ambiente virtual para IA'
sudo apt update
sudo apt install -y python3 python3-pip python3-venv
mkdir -p "$(dirname "$VENV_DIR")"
python3 -m venv "$VENV_DIR"

# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"

pip install --upgrade pip setuptools wheel
pip install \
  jupyterlab \
  numpy pandas scipy matplotlib scikit-learn \
  transformers datasets accelerate sentencepiece \
  opencv-python pillow \
  ipykernel

python -m ipykernel install --user --name ubuntu-ia --display-name "Python (ubuntu-ia)"

echo '==> Ambiente Python para IA pronto'
echo "==> Ative com: source $VENV_DIR/bin/activate"
