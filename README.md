# setup-linux-ia

Setup completo para preparar um Linux (foco em Ubuntu) para **desenvolvimento** + **IA local**, com scripts separados por etapa, execução automática e terminal interativo mais amigável.

## O que você ganha

- Instalação guiada de stack dev (Git, Zsh, Go, Node, Python, Docker, VS Code).
- Etapas para GPU NVIDIA, NVIDIA Container Toolkit, Ollama e teste PyTorch CUDA.
- Scripts **idempotentes** sempre que possível (evita reinstalar o que já existe).
- Modo interativo com:
  - **seleção múltipla** de etapas;
  - **navegação por setas**;
  - **barra de progresso** durante execução;
  - tema mais bonito no terminal usando **gum** (preferencial) ou **whiptail**.

---

## Estrutura do projeto

```text
.
├── README.md
├── Makefile
├── docs
│   └── TROUBLESHOOTING.md
└── scripts
    ├── common.sh
    ├── 00-system-update.sh
    ├── 01-dev-base.sh
    ├── 02-zsh-ohmyzsh.sh
    ├── 03-go.sh
    ├── 04-node-nvm.sh
    ├── 05-python-ia.sh
    ├── 06-docker.sh
    ├── 07-nvidia.sh
    ├── 08-ollama.sh
    ├── 09-validate.sh
    ├── 10-vscode.sh
    ├── 11-nvidia-container-toolkit.sh
    ├── 12-pytorch-gpu-test.sh
    ├── interactive-setup.sh
    └── run-all.sh
```

---

## Uso rápido

### 1) Executar tudo

```bash
chmod +x scripts/*.sh
./scripts/run-all.sh
```

### 2) Executar por etapa

```bash
./scripts/00-system-update.sh
./scripts/01-dev-base.sh
./scripts/02-zsh-ohmyzsh.sh
./scripts/03-go.sh
./scripts/04-node-nvm.sh
./scripts/05-python-ia.sh
./scripts/06-docker.sh
./scripts/07-nvidia.sh
./scripts/08-ollama.sh
./scripts/10-vscode.sh
./scripts/11-nvidia-container-toolkit.sh
./scripts/12-pytorch-gpu-test.sh
./scripts/09-validate.sh
```

### 3) Modo interativo (recomendado)

```bash
./scripts/interactive-setup.sh
```

Com `gum` ou `whiptail` instalados, o menu oferece UX melhor (setas, checklist e progresso). Se nenhum dos dois estiver disponível, o script usa fallback em texto simples.

---

## Backend de interface (gum / whiptail / plain)

O script detecta automaticamente:

1. `gum` (preferência por tema visual mais moderno)
2. `whiptail`
3. fallback `plain` (texto)

### Instalar gum (opcional)

Veja instruções oficiais em: <https://github.com/charmbracelet/gum>

### Instalar whiptail (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y whiptail
```

---

## Ordem recomendada

1. Atualizar sistema
2. Base dev
3. Zsh / Oh My Zsh
4. Go
5. Node via NVM
6. Python IA
7. Docker
8. NVIDIA
9. Ollama
10. VS Code
11. NVIDIA Container Toolkit
12. Teste PyTorch GPU
13. Validação final

---

## O que cada script faz (resumo)

- `scripts/common.sh`: funções utilitárias, logs e status.
- `scripts/00-system-update.sh`: update/upgrade do sistema.
- `scripts/01-dev-base.sh`: pacotes base de desenvolvimento.
- `scripts/02-zsh-ohmyzsh.sh`: Zsh + Oh My Zsh + plugins.
- `scripts/03-go.sh`: Go e ferramentas (`gopls`, `dlv`, etc.).
- `scripts/04-node-nvm.sh`: NVM + Node LTS.
- `scripts/05-python-ia.sh`: venv IA + libs iniciais.
- `scripts/06-docker.sh`: Docker + compose plugin.
- `scripts/07-nvidia.sh`: driver NVIDIA recomendado.
- `scripts/08-ollama.sh`: instalação do Ollama.
- `scripts/09-validate.sh`: checks de versões/binários.
- `scripts/10-vscode.sh`: VS Code repositório oficial.
- `scripts/11-nvidia-container-toolkit.sh`: toolkit para GPU em containers.
- `scripts/12-pytorch-gpu-test.sh`: teste CUDA com PyTorch.
- `scripts/interactive-setup.sh`: painel + menu interativo avançado.
- `scripts/run-all.sh`: execução completa sequencial.

---

## Idempotência (exemplos)

- Oh My Zsh só instala se não existir.
- Plugins Zsh externos só clonam quando ausentes.
- NVM só instala se `~/.nvm` não existir.
- VS Code só instala se `code` não estiver disponível.
- Ollama só instala se o binário não existir.

> Reexecutar o setup é esperado e suportado para manutenção do ambiente.

---

## Troubleshooting

Consulte: [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md)
