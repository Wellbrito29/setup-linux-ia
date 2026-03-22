#!/usr/bin/env bash
set -euo pipefail

echo '==> Instalando base de desenvolvimento'
sudo apt update
sudo apt install -y \
  build-essential \
  curl wget git vim nano unzip zip \
  ca-certificates gnupg lsb-release software-properties-common \
  pkg-config cmake \
  python3 python3-pip python3-venv \
  git-lfs \
  zsh htop tree jq \
  make gcc g++ libc6-dev \
  libssl-dev libsqlite3-dev \
  libbz2-dev libreadline-dev libncursesw5-dev xz-utils tk-dev \
  libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
  libgl1 libglib2.0-0

echo '==> Base instalada com sucesso'
