# setup-linux-ia

Guia completo para preparar um ambiente Linux voltado para **desenvolvimento** e **estudo de IA** com foco em:

- Ubuntu
- Oh My Zsh
- Go
- Node.js
- Python
- Docker
- NVIDIA
- NVIDIA Container Toolkit
- Ollama
- VS Code
- PyTorch com teste de GPU

> Este repositório foi pensado para um setup pessoal em Linux com uma base prática para desenvolvimento backend, frontend, IA local e uso de terminal no dia a dia.

## O que este repositório entrega

- documentação do ambiente
- scripts separados por responsabilidade
- validações pós-instalação
- troubleshooting inicial
- setup de ferramentas para desenvolvimento e IA local
- terminal interativo com menu e execução por etapas
- comportamento idempotente sempre que possível, com skip de itens já instalados

## Estrutura

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

## Modos de uso

### 1. Rodar tudo automaticamente

```bash
chmod +x scripts/*.sh
./scripts/run-all.sh
```

### 2. Rodar por etapas

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

### 3. Usar o terminal interativo

```bash
./scripts/interactive-setup.sh
```

Esse modo mostra um menu como:

- atualizar sistema
- instalar base dev
- configurar zsh
- instalar go
- instalar node
- instalar python ia
- instalar docker
- instalar nvidia
- instalar ollama
- instalar vscode
- instalar nvidia container toolkit
- testar pytorch gpu
- validar ambiente
- rodar tudo

Você escolhe o número da etapa que quer executar. Como os scripts foram escritos para checar itens já instalados, muita coisa será **skipped automaticamente**.

## Idempotência e skips

O objetivo dos scripts é evitar reinstalações desnecessárias. Exemplos:

- Oh My Zsh só instala se a pasta ainda não existir
- plugins externos do Zsh só são clonados se ainda não estiverem presentes
- NVM só instala se `~/.nvm` ainda não existir
- VS Code só instala se o comando `code` ainda não estiver disponível
- Ollama só instala se o binário ainda não existir
- Go é reinstalado pela versão declarada no script, mas você pode trocar `GO_VERSION`

> Alguns componentes, como `apt install`, já são naturalmente seguros para reexecução.

## Ordem recomendada

1. atualizar o sistema
2. instalar pacotes base de desenvolvimento
3. configurar Zsh / Oh My Zsh
4. instalar Go
5. instalar Node.js com NVM
6. instalar Python e libs para IA
7. instalar Docker
8. instalar driver NVIDIA
9. instalar Ollama
10. instalar VS Code
11. instalar NVIDIA Container Toolkit
12. testar PyTorch com GPU
13. validar tudo

## O que cada script faz

### `scripts/common.sh`
Funções compartilhadas para:

- logs padronizados
- checagem de comandos
- detecção de OS
- execução de etapas

### `scripts/00-system-update.sh`
Atualiza índices de pacotes e sobe os upgrades do sistema.

### `scripts/01-dev-base.sh`
Instala ferramentas base para desenvolvimento:

- build-essential
- curl / wget
- git
- unzip / zip
- pkg-config / cmake
- utilitários de terminal
- dependências comuns para compilar bibliotecas

### `scripts/02-zsh-ohmyzsh.sh`
Ajusta o `~/.zshrc` com:

- `GOPATH`
- `PATH` do Go
- `PATH` do Python local
- configuração do NVM
- plugins nativos do Oh My Zsh
- instalação de `zsh-autosuggestions` e `zsh-syntax-highlighting`

### `scripts/03-go.sh`
Instala Go em `/usr/local/go`, define variáveis de ambiente e instala ferramentas úteis:

- `gopls`
- `dlv`
- `staticcheck`
- `goimports`

### `scripts/04-node-nvm.sh`
Instala NVM e a versão LTS do Node.js.

### `scripts/05-python-ia.sh`
Cria um ambiente virtual em `~/venvs/ia`, atualiza `pip` e instala libs iniciais para IA e ciência de dados.

### `scripts/06-docker.sh`
Instala Docker, Compose plugin e adiciona o usuário ao grupo `docker`.

### `scripts/07-nvidia.sh`
Detecta drivers recomendados via `ubuntu-drivers` e instala o recomendado.

### `scripts/08-ollama.sh`
Instala Ollama e mostra comandos básicos para baixar e rodar modelos.

### `scripts/09-validate.sh`
Executa checagens rápidas de versões e disponibilidade dos binários principais.

### `scripts/10-vscode.sh`
Instala VS Code via repositório oficial da Microsoft.

### `scripts/11-nvidia-container-toolkit.sh`
Instala o NVIDIA Container Toolkit para containers Docker com GPU.

### `scripts/12-pytorch-gpu-test.sh`
Instala PyTorch no venv de IA e roda um teste simples de disponibilidade de CUDA.

### `scripts/interactive-setup.sh`
Abre um menu interativo e permite executar uma ou várias etapas sob demanda.

### `scripts/run-all.sh`
Executa todas as etapas em sequência.

## Variáveis e arquivos importantes

### Zsh
O script de Zsh ajusta o `~/.zshrc` com algo próximo de:

```bash
plugins=(git docker golang python pip npm node sudo history zsh-autosuggestions zsh-syntax-highlighting)
```

Também inclui:

```bash
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$HOME/.local/bin:$PATH
export NVM_DIR="$HOME/.nvm"
```

## Ollama
Depois da instalação, alguns comandos úteis:

```bash
ollama --version
ollama serve
ollama list
ollama run llama3.2
ollama ps
```

Para aceitar conexões externas:

```bash
OLLAMA_HOST=0.0.0.0 ollama serve
```

## NVIDIA e IA
Se sua máquina tem GPU NVIDIA, a sequência prática costuma ser:

1. instalar driver
2. reiniciar
3. validar com `nvidia-smi`
4. instalar NVIDIA Container Toolkit
5. testar PyTorch ou Ollama
6. evoluir para containers com GPU quando necessário

## Makefile
Atalhos disponíveis:

```bash
make setup
make interactive
make validate
make ollama
make pytorch-test
```

## Estrutura sugerida do ambiente

```text
~/workspace
~/workspace/go
~/workspace/node
~/workspace/python
~/venvs
~/models
~/datasets
~/go
```

## Validação rápida

Depois de tudo, tente:

```bash
go version
node -v
npm -v
python3 --version
docker --version
ollama --version
code --version
nvidia-smi
```

E no Python:

```bash
source ~/venvs/ia/bin/activate
python -c "import torch; print('cuda available:', torch.cuda.is_available())"
```

## Observações

- alguns scripts exigem logout/login ou reinício
- o script de Docker adiciona seu usuário ao grupo `docker`
- o script da NVIDIA não reinicia automaticamente; você deve reiniciar manualmente
- o script do Ollama instala o serviço, mas o download de modelos é feito separadamente
- para GPU em containers, o driver NVIDIA no host precisa estar funcional antes

## Próximos passos possíveis

- adicionar script para Miniconda
- adicionar script para CUDA em host quando a versão do Ubuntu estiver alinhada ao suporte necessário
- adicionar presets de modelos do Ollama
