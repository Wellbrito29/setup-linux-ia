# Análise técnica do projeto `setup-linux-ia`

## Resumo executivo

O projeto já está bem estruturado para o objetivo de **bootstrap de ambiente Linux para desenvolvimento + IA local**, com pontos fortes claros:

- separação por etapas (`00` a `12`) e execução completa (`run-all.sh`);
- boa preocupação com idempotência em várias instalações;
- experiência interativa acima da média para scripts shell (`gum`/`whiptail`/`plain`);
- foco pragmático em stack moderna (Go, Node, Python, Docker, NVIDIA, Ollama).

A principal oportunidade de evolução está em aumentar:

1. **reprodutibilidade** (versões e checksums),
2. **segurança da cadeia de instalação** (evitar `curl | sh` sem validação),
3. **observabilidade e confiabilidade** (logs estruturados, retries, preflight checks),
4. **portabilidade** (mais distros/arquiteturas),
5. **testabilidade/CI** (smoke tests automatizados em ambiente limpo).

---

## Pontos fortes observados

### 1) Organização e UX

- Sequência de scripts por domínio facilita manutenção e debugging.
- `interactive-setup.sh` oferece status dashboard e seleção de etapas, o que reduz erro humano em setup manual.
- A opção de fallback para modo texto evita hard dependency de UI.

### 2) Idempotência inicial

Há vários checks de “já instalado” antes de reinstalar:

- base dev, Oh My Zsh, NVM, Docker, Ollama, VS Code;
- verificação de módulos Python antes de instalar dependências;
- verificação de toolkit NVIDIA antes de repetir configuração.

### 3) Escopo técnico relevante

O fluxo cobre “do zero ao uso com GPU”:

- toolchain dev + linguagem;
- runtime de containers;
- stack NVIDIA + toolkit para Docker;
- validação com PyTorch CUDA.

---

## Riscos e lacunas atuais

### 1) Segurança de instalação externa

Alguns componentes dependem de scripts remotos diretos (ex.: `curl ... | bash/sh`) e downloads sem checksum explícito. Isso acelera adoção, mas reduz verificabilidade de supply chain.

### 2) Reprodutibilidade de versões

- Go está pinado por variável, porém outros componentes podem variar com “latest/LTS” no momento da execução.
- Dependências Python não estão pinadas com lock file (`requirements.lock`), o que pode gerar ambientes diferentes entre máquinas.

### 3) Compatibilidade e detecção de plataforma

- O README fala em foco Ubuntu/Debian, mas scripts assumem fortemente `apt`, `dpkg`, `ubuntu-drivers`.
- Ainda não há camada clara para distinguir distro/versão/arquitetura e adaptar comportamento.

### 4) Confiabilidade operacional

- Não há política uniforme de retries/backoff para falhas de rede.
- Não existe modo “dry-run/plan” para simular sem alterar sistema.
- Os logs são bons para execução interativa, mas ainda sem trilha consolidada por etapa (arquivo de log por execução).

### 5) Governança e qualidade contínua

- Falta pipeline CI para lint shell, validação sintática e smoke test mínimo.
- Falta changelog/versionamento de release para comunicar mudanças de setup.

---

## Evoluções sugeridas (priorizadas)

## Prioridade alta (curto prazo)

### A) Preflight check obrigatório

Criar etapa inicial que valide:

- distro suportada e versão;
- conexão com endpoints necessários;
- espaço em disco mínimo;
- presença de `sudo` funcional;
- arquitetura (`amd64/arm64`) e capacidade de GPU.

**Benefício:** falhar cedo com mensagem clara, evitando setups parcialmente aplicados.

### B) Hardening de downloads e install scripts

- Sempre que possível, substituir `curl | sh` por fluxo com download + checksum + execução.
- Quando não for possível evitar script remoto, validar origem e versão esperada.
- Padronizar `set -euo pipefail` + mensagens de erro consistentes em todos os scripts.

**Benefício:** melhora segurança e auditabilidade.

### C) Padrão único de logging e relatório final

- Salvar logs em `~/.local/state/setup-linux-ia/<timestamp>/`.
- Registrar status por etapa (ok/skip/fail, duração, comando principal).
- Gerar resumo final com “próximas ações” (ex.: reboot pendente, relogin para grupo docker).

**Benefício:** troubleshooting muito mais rápido.

## Prioridade média (médio prazo)

### D) Reprodutibilidade real de Python/Node

- Introduzir arquivo de dependências pinado para Python (`requirements.txt` + lock).
- Para Node (se houver uso futuro), documentar versão LTS alvo e política de upgrade.
- Expor variáveis de versão em um arquivo central (`versions.env`).

**Benefício:** ambientes mais determinísticos em times/equipes.

### E) Modularização por perfis

Adicionar “profiles” prontos, por exemplo:

- `profile=minimal-dev`
- `profile=ia-cpu`
- `profile=ia-gpu-nvidia`
- `profile=full`

**Benefício:** reduz tempo de setup e evita instalar componentes desnecessários.

### F) Modo não interativo robusto

- Flags CLI para escolher etapas (`--only`, `--skip`, `--from`, `--to`).
- Modo CI/headless sem prompts de confirmação.

**Benefício:** automação em cloud-init, golden images e runners CI.

## Prioridade estratégica (longo prazo)

### G) Testes automatizados em ambiente efêmero

- CI com shellcheck + shfmt + testes de smoke.
- Teste em VM/container limpo para validar ordem e idempotência (ao menos CPU path).

### H) “Doctor” contínuo

Expandir `09-validate.sh` para um comando de diagnóstico:

- valida versões mínimas;
- aponta drift de configuração;
- oferece sugestões automáticas de correção.

### I) Documentação de operação e rollback

- matrizes de suporte (Ubuntu 22.04/24.04, arch);
- plano de rollback de componentes sensíveis (driver NVIDIA, Docker runtime);
- seção de segurança (origem de artefatos, como auditar).

---

## Roadmap sugerido (90 dias)

### Fase 1 (0–30 dias)
- Preflight checks;
- logs por execução;
- padronização de erros e mensagens;
- versão centralizada em `versions.env`.

### Fase 2 (31–60 dias)
- profiles (`minimal-dev`, `ia-cpu`, `ia-gpu-nvidia`);
- flags não interativas;
- lock de dependências Python.

### Fase 3 (61–90 dias)
- CI com lint + smoke test;
- evolução do `validate` para `doctor`;
- documentação de suporte/rollback.

---

## Métricas de sucesso recomendadas

- **Taxa de sucesso de primeira execução** em máquina limpa;
- **tempo total de setup** por perfil;
- **taxa de reexecução idempotente sem erro**;
- **MTTR de troubleshooting** (tempo para resolver falhas comuns);
- **número de incidentes de incompatibilidade por release**.

---

## Conclusão

O projeto já entrega valor prático e tem base sólida de scripts. Com foco nas evoluções de **segurança**, **reprodutibilidade**, **automação** e **testes**, ele pode evoluir rapidamente de “setup útil para uso pessoal” para “framework de provisionamento confiável para times”.
