#!/usr/bin/env bash
set -euo pipefail

GO_VERSION="${GO_VERSION:-1.24.2}"

export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Verifica se a versão correta já está instalada
if command -v /usr/local/go/bin/go >/dev/null 2>&1; then
  installed=$(/usr/local/go/bin/go version | grep -oP 'go\K[0-9.]+' || echo '')
  if [[ "$installed" == "$GO_VERSION" ]]; then
    echo "[skip] Go $GO_VERSION já instalado"
    /usr/local/go/bin/go version
    exit 0
  fi
  echo "==> Go $installed encontrado, atualizando para $GO_VERSION"
fi

GO_TARBALL="go${GO_VERSION}.linux-amd64.tar.gz"
GO_URL="https://go.dev/dl/${GO_TARBALL}"

echo "==> Instalando Go ${GO_VERSION}"
cd /tmp
wget -q --show-progress "$GO_URL"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "$GO_TARBALL"
rm -f "/tmp/$GO_TARBALL"

mkdir -p "$GOPATH/bin" "$GOPATH/pkg" "$GOPATH/src"

echo '==> Instalando ferramentas úteis do Go'
/usr/local/go/bin/go install golang.org/x/tools/gopls@latest
/usr/local/go/bin/go install github.com/go-delve/delve/cmd/dlv@latest
/usr/local/go/bin/go install honnef.co/go/tools/cmd/staticcheck@latest
/usr/local/go/bin/go install golang.org/x/tools/cmd/goimports@latest

echo '==> Go instalado com sucesso'
/usr/local/go/bin/go version
