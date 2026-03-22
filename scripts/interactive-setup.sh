#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

STEP_LABELS=(
  'Atualizar sistema'
  'Instalar base dev'
  'Configurar Zsh / Oh My Zsh'
  'Instalar Go'
  'Instalar Node via NVM'
  'Instalar Python IA'
  'Instalar Docker'
  'Instalar NVIDIA'
  'Instalar Ollama'
  'Instalar VS Code'
  'Instalar NVIDIA Container Toolkit'
  'Testar PyTorch GPU'
  'Validar ambiente'
)

STEP_SCRIPTS=(
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
)

ui_backend='plain'
if has_cmd gum && [[ -t 1 ]]; then
  ui_backend='gum'
elif has_cmd whiptail && [[ -t 1 ]]; then
  ui_backend='whiptail'
fi

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

gum_banner() {
  gum style --foreground 212 --border rounded --border-foreground 99 --padding '0 1' \
    'setup-linux-ia :: assistente interativo'
}

text_progress_bar() {
  local current="$1"
  local total="$2"
  local width=30
  local filled=$(( current * width / total ))
  local empty=$(( width - filled ))
  printf '%*s' "$filled" '' | tr ' ' '█'
  printf '%*s' "$empty" '' | tr ' ' '░'
}

run_selected_steps_plain() {
  local -a indexes=("$@")
  local total="${#indexes[@]}"
  local i idx

  for i in "${!indexes[@]}"; do
    idx="${indexes[$i]}"
    run_step "${STEP_LABELS[$idx]}" "${STEP_SCRIPTS[$idx]}"

    local done_count=$(( i + 1 ))
    local percent=$(( done_count * 100 / total ))
    local bar
    bar="$(text_progress_bar "$done_count" "$total")"
    printf '%b[%3d%%]%b %s (%d/%d)\n' "$C_CYAN" "$percent" "$C_RESET" "$bar" "$done_count" "$total"
  done
}

run_selected_steps_whiptail() {
  local -a indexes=("$@")
  local total="${#indexes[@]}"
  local i idx

  {
    echo 0
    echo "XXX"
    echo "Iniciando execução..."
    echo "XXX"

    for i in "${!indexes[@]}"; do
      idx="${indexes[$i]}"
      run_step "${STEP_LABELS[$idx]}" "${STEP_SCRIPTS[$idx]}"
      local percent=$(( (i + 1) * 100 / total ))
      echo "$percent"
      echo "XXX"
      echo "${STEP_LABELS[$idx]} concluído (${i + 1}/${total})"
      echo "XXX"
    done
  } | whiptail --gauge 'Executando etapas selecionadas...' 12 80 0
}

run_selected_steps() {
  local -a indexes=("$@")
  if [[ "${#indexes[@]}" -eq 0 ]]; then
    warn 'Nenhuma etapa selecionada.'
    return 0
  fi

  case "$ui_backend" in
    whiptail) run_selected_steps_whiptail "${indexes[@]}" ;;
    *) run_selected_steps_plain "${indexes[@]}" ;;
  esac
}

pick_steps_whiptail() {
  local -a options=()
  local i
  for i in "${!STEP_LABELS[@]}"; do
    options+=("$i" "${STEP_LABELS[$i]}" OFF)
  done

  local raw
  if ! raw=$(whiptail --title 'Selecionar etapas (múltipla escolha)' \
    --checklist 'Use setas para navegar e espaço para marcar:' 22 90 14 \
    "${options[@]}" 3>&1 1>&2 2>&3); then
    return 1
  fi

  # shellcheck disable=SC2206
  local -a selected=( $raw )
  local -a indexes=()
  for item in "${selected[@]}"; do
    indexes+=("${item//\"/}")
  done
  printf '%s\n' "${indexes[@]}"
}

pick_steps_gum() {
  local output
  if ! output=$(printf '%s\n' "${STEP_LABELS[@]}" | \
    gum choose --no-limit --header 'Selecione as etapas (↑↓ para navegar, espaço para marcar, enter para confirmar):'); then
    return 1
  fi

  local -a indexes=()
  local line i
  while IFS= read -r line; do
    for i in "${!STEP_LABELS[@]}"; do
      if [[ "${STEP_LABELS[$i]}" == "$line" ]]; then
        indexes+=("$i")
        break
      fi
    done
  done <<< "$output"

  printf '%s\n' "${indexes[@]}"
}

pick_steps_plain() {
  local i
  printf 'Digite uma ou mais opções separadas por espaço:\n'
  for i in "${!STEP_LABELS[@]}"; do
    printf '  %2d) %s\n' "$((i + 1))" "${STEP_LABELS[$i]}"
  done

  local answer
  read -r -p 'Opções: ' answer

  local -a raw
  # shellcheck disable=SC2206
  raw=( $answer )

  local -a indexes=()
  local item
  for item in "${raw[@]}"; do
    if [[ "$item" =~ ^[0-9]+$ ]] && (( item >= 1 && item <= ${#STEP_LABELS[@]} )); then
      indexes+=("$((item - 1))")
    fi
  done

  printf '%s\n' "${indexes[@]}"
}

pick_steps() {
  case "$ui_backend" in
    gum) pick_steps_gum ;;
    whiptail) pick_steps_whiptail ;;
    *) pick_steps_plain ;;
  esac
}

pick_action() {
  case "$ui_backend" in
    gum)
      gum_banner
      gum choose \
        'Executar etapas selecionadas' \
        'Rodar setup completo' \
        'Atualizar painel de status' \
        'Sair'
      ;;
    whiptail)
      whiptail --title 'setup-linux-ia' --menu 'Escolha uma ação:' 16 70 6 \
        1 'Executar etapas selecionadas' \
        2 'Rodar setup completo' \
        3 'Atualizar painel de status' \
        0 'Sair' 3>&1 1>&2 2>&3
      ;;
    *)
      cat <<'TXT'
=== setup-linux-ia ===
1) Executar etapas selecionadas
2) Rodar setup completo
3) Atualizar painel de status
0) Sair
TXT
      read -r -p 'Escolha uma opção: ' opt
      case "$opt" in
        1) echo 'Executar etapas selecionadas' ;;
        2) echo 'Rodar setup completo' ;;
        3) echo 'Atualizar painel de status' ;;
        *) echo 'Sair' ;;
      esac
      ;;
  esac
}

while true; do
  print_status_dashboard

  if ! action=$(pick_action); then
    break
  fi

  case "$action" in
    1|'Executar etapas selecionadas')
      if selected=$(pick_steps); then
        mapfile -t indexes <<< "$selected"
        run_selected_steps "${indexes[@]}"
      fi
      pause
      ;;
    2|'Rodar setup completo')
      run_step 'Setup completo' "$SCRIPT_DIR/run-all.sh"
      pause
      ;;
    3|'Atualizar painel de status')
      ;;
    0|'Sair')
      exit 0
      ;;
    *)
      warn 'Ação inválida.'
      pause
      ;;
  esac
done
