# Troubleshooting

## `ubuntu-drivers autoinstall` não funciona
Em algumas versões o comando pode não existir como esperado. Use:

```bash
ubuntu-drivers devices
sudo ubuntu-drivers install
```

## `nvidia-smi` não funciona
Verifique:

- se o driver foi instalado
- se você reiniciou após a instalação
- se o Secure Boot está bloqueando o módulo da NVIDIA

## Docker pede sudo mesmo após instalação
Você provavelmente ainda precisa reiniciar a sessão:

```bash
newgrp docker
```

Se continuar, faça logout/login.

## Oh My Zsh reclama de plugin inexistente
Rode:

```bash
ls ~/.oh-my-zsh/plugins
```

Se o plugin não existir, remova ele do `plugins=(...)` ou instale o plugin externo.

## `nvm` não encontrado
Verifique se estas linhas existem no `~/.zshrc`:

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

Depois rode:

```bash
source ~/.zshrc
```

## Ollama não expõe na rede
Para aceitar conexões externas:

```bash
OLLAMA_HOST=0.0.0.0 ollama serve
```

## Modelo do Ollama não apareceu depois
Liste os modelos:

```bash
ollama list
```

Os modelos ficam persistidos em disco; se não aparecerem, valide se você não estava em outro ambiente/instância.

## Uso de GPU no Ollama
Verifique com:

```bash
ollama ps
```

Se necessário, confira também:

```bash
nvidia-smi
```

## Python de IA falha ao instalar libs
Atualize ferramentas base:

```bash
pip install --upgrade pip setuptools wheel
```

E confirme se as libs nativas estão instaladas via `01-dev-base.sh`.
