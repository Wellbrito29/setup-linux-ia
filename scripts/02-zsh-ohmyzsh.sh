#!/usr/bin/env bash
set -euo pipefail

ZSHRC="$HOME/.zshrc"
OHMYZSH_DIR="$HOME/.oh-my-zsh"
CUSTOM_DIR="${ZSH_CUSTOM:-$OHMYZSH_DIR/custom}"

echo '==> Garantindo que zsh e git estão instalados'
sudo apt update
sudo apt install -y zsh git curl

if [ ! -d "$OHMYZSH_DIR" ]; then
  echo '==> Instalando Oh My Zsh'
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo '==> Oh My Zsh já está instalado'
fi

mkdir -p "$CUSTOM_DIR/plugins"

if [ ! -d "$CUSTOM_DIR/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$CUSTOM_DIR/plugins/zsh-autosuggestions"
fi

if [ ! -d "$CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$CUSTOM_DIR/plugins/zsh-syntax-highlighting"
fi

touch "$ZSHRC"

append_if_missing() {
  local line="$1"
  grep -Fqx "$line" "$ZSHRC" || echo "$line" >> "$ZSHRC"
}

if grep -q '^plugins=' "$ZSHRC"; then
  sed -i 's/^plugins=.*/plugins=(git docker golang python pip npm node sudo history zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC"
else
  echo 'plugins=(git docker golang python pip npm node sudo history zsh-autosuggestions zsh-syntax-highlighting)' >> "$ZSHRC"
fi

append_if_missing ''
append_if_missing '# Go'
append_if_missing 'export PATH=$PATH:/usr/local/go/bin'
append_if_missing 'export GOPATH=$HOME/go'
append_if_missing 'export PATH=$PATH:$GOPATH/bin'
append_if_missing ''
append_if_missing '# Python'
append_if_missing 'export PATH=$HOME/.local/bin:$PATH'
append_if_missing ''
append_if_missing '# Node via NVM'
append_if_missing 'export NVM_DIR="$HOME/.nvm"'
append_if_missing '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
append_if_missing '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
append_if_missing ''
append_if_missing 'export EDITOR=nano'

echo '==> Zsh / Oh My Zsh configurados'
echo '==> Rode: source ~/.zshrc'
