# setup-linux-ia

Guia completo para preparar um ambiente Linux voltado para **desenvolvimento** e **estudo de IA** com foco em:

- Ubuntu
- Oh My Zsh
- Go
- Node.js
- Python
- Docker
- NVIDIA
- Ollama

> Este repositório foi pensado para um setup pessoal em Linux com uma base prática para desenvolvimento backend, frontend, IA local e uso de terminal no dia a dia.

## O que este repositório entrega

- documentação do ambiente
- scripts separados por responsabilidade
- validações pós-instalação
- troubleshooting inicial
- setup de ferramentas para desenvolvimento e IA local

## Estrutura

```text
.
├── README.md
├── docs
│   └── TROUBLESHOOTING.md
└── scripts
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
    └── run-all.sh
```

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
10. validar tudo

## Como usar

Dê permissão de execução:

```bash
chmod +x scripts/*.sh
```

Rode os scripts individualmente:

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
./scripts/09-validate.sh
```

Ou use o agregador:

```bash
./scripts/run-all.sh
```

## O que cada script faz

### `00-system-update.sh`
Atualiza índices de pacotes e sobe os upgrades do sistema.

### `01-dev-base.sh`
Instala ferramentas base para desenvolvimento:

- build-essential
- curl / wget
- git
- unzip / zip
- pkg-config / cmake
- utilitários de terminal
- dependências comuns para compilar bibliotecas

### `02-zsh-ohmyzsh.sh`
Ajusta o `~/.zshrc` com:

- `GOPATH`
- `PATH` do Go
- `PATH` do Python local
- configuração do NVM
- plugins nativos do Oh My Zsh
- instalação opcional de `zsh-autosuggestions` e `zsh-syntax-highlighting`

### `03-go.sh`
Instala Go em `/usr/local/go`, define variáveis de ambiente e instala ferramentas úteis:

- `gopls`
- `dlv`
- `staticcheck`
- `goimports`

### `04-node-nvm.sh`
Instala NVM e a versão LTS do Node.js.

### `05-python-ia.sh`
Cria um ambiente virtual em `~/venvs/ia`, atualiza `pip` e instala libs iniciais para IA e ciência de dados:

- jupyterlab
- numpy
- pandas
- scipy
- matplotlib
- scikit-learn
- transformers
- datasets
- accelerate
- sentencepiece
- opencv-python
- pillow
- ipykernel

### `06-docker.sh`
Instala Docker, Compose plugin e adiciona o usuário ao grupo `docker`.

### `07-nvidia.sh`
Detecta drivers recomendados via `ubuntu-drivers` e instala o recomendado.

> Observação: dependendo da sua versão do Ubuntu, o suporte para CUDA no host pode variar. Em muitos cenários de IA local, uma estratégia prática é usar **driver NVIDIA + frameworks Python** ou **Docker com GPU**, em vez de instalar todo o stack CUDA manualmente no host logo de cara.

### `08-ollama.sh`
Instala Ollama, habilita o serviço e mostra comandos básicos para baixar e rodar modelos.

### `09-validate.sh`
Executa checagens rápidas de versões e disponibilidade dos binários principais.

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
```

Para verificar uso de GPU em execução:

```bash
ollama ps
```

## NVIDIA e IA
Se sua máquina tem GPU NVIDIA, a sequência prática costuma ser:

1. instalar driver
2. reiniciar
3. validar com `nvidia-smi`
4. testar PyTorch ou Ollama
5. se necessário, evoluir para containers com GPU

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
nvidia-smi
```

E no Python:

```bash
source ~/venvs/ia/bin/activate
python -c "import numpy, pandas, sklearn, transformers; print('python ia ok')"
```

## Observações

- alguns scripts exigem logout/login ou reinício
- o script de Docker adiciona seu usuário ao grupo `docker`
- o script da NVIDIA não reinicia automaticamente; você deve reiniciar manualmente
- o script do Ollama instala o serviço, mas o download de modelos é feito separadamente

## Próximos passos possíveis

- adicionar script para NVIDIA Container Toolkit
- adicionar script para VS Code
- adicionar script para Miniconda
- adicionar script para CUDA em host quando a versão do Ubuntu estiver alinhada ao suporte necessário
