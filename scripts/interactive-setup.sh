#!/usr/bin/env bash

if [[ "$EUID" -eq 0 ]]; then
  echo 'Erro: não rode este script com sudo.'
  echo 'Execute como usuário normal: bash scripts/interactive-setup.sh'
  echo 'Os scripts internos chamam sudo quando necessário.'
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

# Garante que o terminal seja restaurado em qualquer saída (erro, Ctrl+C, etc.)
trap 'tput reset 2>/dev/null || reset 2>/dev/null || true' EXIT INT TERM

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

GUM_TITLE_COLOR='#D946EF'
GUM_ACCENT_COLOR='#7C3AED'
GUM_SUCCESS_COLOR='#22C55E'
GUM_WARNING_COLOR='#F59E0B'

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
  if [[ "$ui_backend" == 'whiptail' ]]; then
    local text
    text=$(
      C_RESET='' C_BOLD='' C_DIM='' C_RED='' C_GREEN=''
      C_YELLOW='' C_BLUE='' C_MAGENTA='' C_CYAN=''
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
    )
    whiptail --title 'setup-linux-ia :: painel de status' \
      --msgbox "$(printf 'Ambiente atual:\n\n%s' "$text")" 22 60 </dev/tty >/dev/tty
    return
  fi

  clear || true
  if [[ "$ui_backend" == 'gum' ]]; then
    gum style --foreground "$GUM_TITLE_COLOR" --bold 'setup-linux-ia :: painel de status'
    gum style --foreground 245 'Ambiente atual'
    printf '\n'
  else
    title 'setup-linux-ia :: painel de status'
    printf '%bAmbiente atual%b\n\n' "$C_DIM" "$C_RESET"
  fi

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
  gum style --foreground "$GUM_TITLE_COLOR" --border rounded --border-foreground "$GUM_ACCENT_COLOR" --padding '0 1' \
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
    run_step "${STEP_LABELS[$idx]}" "${STEP_SCRIPTS[$idx]}" || \
      warn "Etapa '${STEP_LABELS[$idx]}' falhou. Continuando..."

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
  local -a failed=()

  for i in "${!indexes[@]}"; do
    idx="${indexes[$i]}"
    local label="${STEP_LABELS[$idx]}"
    local percent=$(( i * 100 / total ))
    whiptail --infobox "[$(( i + 1 ))/$total] Executando: $label" 7 60 >/dev/tty

    local log_file
    log_file=$(mktemp)
    if ! bash "${STEP_SCRIPTS[$idx]}" >"$log_file" 2>&1; then
      failed+=("$label")
      whiptail --title "Erro: $label" --scrolltext --textbox "$log_file" 20 80 >/dev/tty </dev/tty
    fi
    rm -f "$log_file"
  done

  if [[ ${#failed[@]} -gt 0 ]]; then
    local msg="Etapas com falha:\n"
    for s in "${failed[@]}"; do msg+="  - $s\n"; done
    whiptail --title 'Resultado' --msgbox "$msg" 15 60 >/dev/tty </dev/tty
  else
    whiptail --title 'Concluído' --msgbox 'Todas as etapas foram concluídas.' 8 50 >/dev/tty </dev/tty
  fi
}

run_selected_steps_gum() {
  local -a indexes=("$@")
  local total="${#indexes[@]}"
  local i idx

  for i in "${!indexes[@]}"; do
    idx="${indexes[$i]}"
    gum style --foreground "$GUM_WARNING_COLOR" "→ ${STEP_LABELS[$idx]}"
    local done_count=$(( i + 1 ))
    local percent=$(( done_count * 100 / total ))
    if gum spin --spinner dot --title "Executando etapa..." -- bash "${STEP_SCRIPTS[$idx]}"; then
      gum style --foreground "$GUM_SUCCESS_COLOR" "✓ ${STEP_LABELS[$idx]} concluído (${done_count}/${total})"
    else
      gum style --foreground "$GUM_WARNING_COLOR" "✗ ${STEP_LABELS[$idx]} falhou (${done_count}/${total})"
    fi
    gum style --foreground "$GUM_ACCENT_COLOR" "Progresso geral: ${percent}%"
  done
}

# Retorna 0 se a etapa já está instalada/ok, 1 se está pendente
step_is_ok() {
  local idx="$1"
  case "$idx" in
    0) return 1 ;;  # system update: sempre reexecutável
    1) has_cmd git && has_cmd curl && has_cmd gcc && has_cmd python3 && has_cmd make ;;
    2) [[ -d "$HOME/.oh-my-zsh" ]] && grep -q 'zsh-autosuggestions' "$HOME/.zshrc" 2>/dev/null ;;
    3) has_cmd go ;;
    4) has_cmd node && has_cmd npm ;;
    5) [[ -d "$HOME/venvs/ia" ]] ;;
    6) has_cmd docker ;;
    7) has_cmd nvidia-smi ;;
    8) has_cmd ollama ;;
    9) has_cmd code ;;
    10) dpkg -s nvidia-container-toolkit >/dev/null 2>&1 ;;
    11)
      [[ -d "$HOME/venvs/ia" ]] && "$HOME/venvs/ia/bin/python" - <<'PY' >/dev/null 2>&1
import importlib.util, sys
sys.exit(0 if importlib.util.find_spec('torch') else 1)
PY
      ;;
    12) return 1 ;;  # validate: sempre reexecutável
    *) return 1 ;;
  esac
}

get_pending_indexes() {
  local i
  for i in "${!STEP_LABELS[@]}"; do
    if ! step_is_ok "$i"; then
      printf '%s\n' "$i"
    fi
  done
}

run_selected_steps() {
  local -a indexes=("$@")
  if [[ "${#indexes[@]}" -eq 0 ]]; then
    warn 'Nenhuma etapa selecionada.'
    return 0
  fi

  case "$ui_backend" in
    gum) run_selected_steps_gum "${indexes[@]}" ;;
    whiptail) run_selected_steps_whiptail "${indexes[@]}" ;;
    *) run_selected_steps_plain "${indexes[@]}" ;;
  esac
}

pick_steps_whiptail() {
  local out="$1"
  local -a options=()
  local i
  for i in "${!STEP_LABELS[@]}"; do
    options+=("$i" "${STEP_LABELS[$i]}" OFF)
  done

  local tmp
  tmp=$(mktemp)
  whiptail --title 'Selecionar etapas (múltipla escolha)' \
    --checklist 'Use setas para navegar e espaço para marcar:' 22 90 14 \
    "${options[@]}" 2>"$tmp" || { rm -f "$tmp"; return 1; }

  # shellcheck disable=SC2206
  local -a selected=( $(cat "$tmp") )
  rm -f "$tmp"

  local item
  for item in "${selected[@]}"; do
    printf '%s\n' "${item//\"/}"
  done > "$out"
}

pick_steps_gum() {
  local output
  if ! output=$(gum choose --no-limit \
    --header 'Selecione as etapas (↑↓ para navegar, espaço para marcar, enter para confirmar):' \
    "${STEP_LABELS[@]}"); then
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
  printf 'Digite uma ou mais opções separadas por espaço:\n' >/dev/tty
  for i in "${!STEP_LABELS[@]}"; do
    printf '  %2d) %s\n' "$((i + 1))" "${STEP_LABELS[$i]}" >/dev/tty
  done

  local answer
  read -r -p 'Opções: ' answer </dev/tty

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

# $1 = arquivo onde o resultado será escrito
# retorna 0 se uma ação foi escolhida, 1 se o usuário cancelou
pick_action() {
  local out="$1"
  case "$ui_backend" in
    gum)
      gum_banner
      gum style --foreground 245 --margin '1 0' \
        'Use ↑↓ para navegar e Enter para confirmar.'
      gum choose \
        'Executar etapas selecionadas' \
        'Executar apenas pendentes' \
        'Rodar setup completo' \
        'Atualizar painel de status' \
        'Sair' > "$out"
      ;;
    whiptail)
      whiptail --title 'setup-linux-ia' --menu 'Escolha uma ação:' 18 70 7 \
        1 'Executar etapas selecionadas' \
        4 'Executar apenas pendentes' \
        2 'Rodar setup completo' \
        3 'Atualizar painel de status' \
        0 'Sair' 2>"$out" || return 1
      ;;
    *)
      cat <<'TXT'
=== setup-linux-ia ===
1) Executar etapas selecionadas
4) Executar apenas pendentes
2) Rodar setup completo
3) Atualizar painel de status
0) Sair
TXT
      local opt
      read -r -p 'Escolha uma opção: ' opt
      case "$opt" in
        1) echo 'Executar etapas selecionadas' ;;
        4) echo 'Executar apenas pendentes' ;;
        2) echo 'Rodar setup completo' ;;
        3) echo 'Atualizar painel de status' ;;
        *) echo 'Sair' ;;
      esac > "$out"
      ;;
  esac
}

# $1 = arquivo onde os índices selecionados serão escritos (um por linha)
pick_steps() {
  local out="$1"
  case "$ui_backend" in
    gum) pick_steps_gum > "$out" ;;
    whiptail) pick_steps_whiptail "$out" ;;
    *) pick_steps_plain > "$out" ;;
  esac
}

_ACTION_FILE=$(mktemp)
_STEPS_FILE=$(mktemp)
trap 'rm -f "$_ACTION_FILE" "$_STEPS_FILE"; tput reset 2>/dev/null || true' EXIT INT TERM

while true; do
  print_status_dashboard

  if ! pick_action "$_ACTION_FILE"; then
    continue
  fi
  action=$(cat "$_ACTION_FILE")

  case "$action" in
    1|'Executar etapas selecionadas')
      if pick_steps "$_STEPS_FILE" && [[ -s "$_STEPS_FILE" ]]; then
        mapfile -t indexes < "$_STEPS_FILE"
        run_selected_steps "${indexes[@]}"
      fi
      pause
      ;;
    4|'Executar apenas pendentes')
      get_pending_indexes > "$_STEPS_FILE"
      if [[ -s "$_STEPS_FILE" ]]; then
        mapfile -t indexes < "$_STEPS_FILE"
        run_selected_steps "${indexes[@]}"
      else
        ok 'Tudo já está instalado!'
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
      break
      ;;
    *)
      warn 'Ação inválida.'
      pause
      ;;
  esac
done
