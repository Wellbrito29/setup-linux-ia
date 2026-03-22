#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

check_system() {
  status_line 'Sistema atualizado' partial 'sempre reexecutável via apt'
}

check_dev_base() {
  if has_cmd git && has_cmd curl && has_cmd python3; then
    status_line 'Base dev' ok
  else
    status_line 'Base dev' pending
  fi
}

check_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]] && grep -q 'zsh-autosuggestions' "$HOME/.zshrc" 2>/dev/null; then
    status_line 'Zsh / Oh My Zsh' ok
  elif [[ -d "$HOME/.oh-my-zsh" ]]; then
    status_line 'Zsh / Oh My Zsh' partial 'Oh My Zsh existe, revisar ~/.zshrc'
  else
    status_line 'Zsh / Oh My Zsh' pending
  fi
}

check_go() {
  if has_cmd go; then
    status_line 'Go' ok "$(go version 2>/dev/null | head -n 1)"
  else
    status_line 'Go' pending
  fi
}

check_node() {
  if has_cmd node && has_cmd npm; then
    status_line 'Node / NPM' ok "node $(node -v 2>/dev/null)"
  else
    status_line 'Node / NPM' pending
  fi
}

check_python_ia() {
  if [[ -d "$HOME/venvs/ia" ]]; then
    status_line 'Python IA venv' ok "$HOME/venvs/ia"
  else
    status_line 'Python IA venv' pending
  fi
}

check_docker() {
  if has_cmd docker; then
    status_line 'Docker' ok
  else
    status_line 'Docker' pending
  fi
}

check_nvidia() {
  if has_cmd nvidia-smi; then
    status_line 'NVIDIA driver' ok
  else
    status_line 'NVIDIA driver' pending
  fi
}

check_ollama() {
  if has_cmd ollama; then
    status_line 'Ollama' ok
  else
    status_line 'Ollama' pending
  fi
}

check_vscode() {
  if has_cmd code; then
    status_line 'VS Code' ok
  else
    status_line 'VS Code' pending
  fi
}

check_nvidia_toolkit() {
  if dpkg -s nvidia-container-toolkit >/dev/null 2>&1; then
    status_line 'NVIDIA Toolkit' ok
  else
    status_line 'NVIDIA Toolkit' pending
  fi
}

check_pytorch() {
  if [[ -d "$HOME/venvs/ia" ]] && "$HOME/venvs/ia/bin/python" - <<'PY' >/dev/null 2>&1
import importlib.util, sys
sys.exit(0 if importlib.util.find_spec('torch') else 1)
PY
  then
    status_line 'PyTorch' ok
  else
    status_line 'PyTorch' pending
  fi
}

print_status_dashboard() {
  clear || true
  title 'setup-linux-ia :: painel de status'
  printf '%bAmbiente atual%b\n\n' "$C_DIM" "$C_RESET"
  check_system
  check_dev_base
  check_zsh
  check_go
  check_node
  check_python_ia
  check_docker
  check_nvidia
  check_ollama
  check_vscode
  check_nvidia_toolkit
  check_pytorch
  printf '\n'
}

menu() {
  cat <<EOF
${C_BOLD}=== setup-linux-ia ===${C_RESET}
1) Atualizar sistema
2) Instalar base dev
3) Configurar Zsh / Oh My Zsh
4) Instalar Go
5) Instalar Node via NVM
6) Instalar Python IA
7) Instalar Docker
8) Instalar NVIDIA
9) Instalar Ollama
10) Instalar VS Code
11) Instalar NVIDIA Container Toolkit
12) Testar PyTorch GPU
13) Validar ambiente
14) Rodar tudo
15) Atualizar painel de status
0) Sair
EOF
}

while true; do
  print_status_dashboard
  menu
  read -rp 'Escolha uma opção: ' choice
  case "$choice" in
    1) run_step 'Atualizar sistema' "$SCRIPT_DIR/00-system-update.sh"; pause ;;
    2) run_step 'Base dev' "$SCRIPT_DIR/01-dev-base.sh"; pause ;;
    3) run_step 'Zsh / Oh My Zsh' "$SCRIPT_DIR/02-zsh-ohmyzsh.sh"; pause ;;
    4) run_step 'Go' "$SCRIPT_DIR/03-go.sh"; pause ;;
    5) run_step 'Node via NVM' "$SCRIPT_DIR/04-node-nvm.sh"; pause ;;
    6) run_step 'Python IA' "$SCRIPT_DIR/05-python-ia.sh"; pause ;;
    7) run_step 'Docker' "$SCRIPT_DIR/06-docker.sh"; pause ;;
    8) run_step 'NVIDIA' "$SCRIPT_DIR/07-nvidia.sh"; pause ;;
    9) run_step 'Ollama' "$SCRIPT_DIR/08-ollama.sh"; pause ;;
    10) run_step 'VS Code' "$SCRIPT_DIR/10-vscode.sh"; pause ;;
    11) run_step 'NVIDIA Container Toolkit' "$SCRIPT_DIR/11-nvidia-container-toolkit.sh"; pause ;;
    12) run_step 'PyTorch GPU test' "$SCRIPT_DIR/12-pytorch-gpu-test.sh"; pause ;;
    13) run_step 'Validar ambiente' "$SCRIPT_DIR/09-validate.sh"; pause ;;
    14) run_step 'Setup completo' "$SCRIPT_DIR/run-all.sh"; pause ;;
    15) : ;;
    0) exit 0 ;;
    *) warn 'Opção inválida'; pause ;;
  esac
done
