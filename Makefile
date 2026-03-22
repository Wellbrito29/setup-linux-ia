SHELL := /bin/bash

.PHONY: setup interactive validate ollama pytorch-test vscode nvidia-toolkit base

setup:
	chmod +x scripts/*.sh
	./scripts/run-all.sh

interactive:
	chmod +x scripts/*.sh
	./scripts/interactive-setup.sh

validate:
	chmod +x scripts/*.sh
	./scripts/09-validate.sh

ollama:
	chmod +x scripts/*.sh
	./scripts/08-ollama.sh

pytorch-test:
	chmod +x scripts/*.sh
	./scripts/12-pytorch-gpu-test.sh

vscode:
	chmod +x scripts/*.sh
	./scripts/10-vscode.sh

nvidia-toolkit:
	chmod +x scripts/*.sh
	./scripts/11-nvidia-container-toolkit.sh

base:
	chmod +x scripts/*.sh
	./scripts/00-system-update.sh
	./scripts/01-dev-base.sh
