SHELL:=/bin/bash

.PHONY: help restart-mining start-mining stop-mining tail-logs

check_requirements=/bin/bash -c "source ./bin/console.sh && check_requirements"

run_with_docker=docker-compose --project-name=packetcrypt_rs up --force-recreate --remove-orphans --detach
ifeq ($(shell test -e docker-compose-test.override.yml; echo $$?), 0)
	run_with_docker=docker-compose -f docker-compose.yml -f docker-compose.override.yml --project-name=packetcrypt_rs up --force-recreate --remove-orphans --detach
endif

list_running_packetcrypt_rs-containers=docker ps -a --format '{{ .ID }}\t{{.Image}}\t{{.Names}}' | \grep packetcrypt_rs | \awk -v FS='\t' -v OFS='\t' '{print $$1}'

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build container
	@/bin/bash -c "docker build --compress --tag packetcrypt_rs ."

start-mining: ## Run container requiring having exported a wallet address and mining pools (whitespace-separated) as environment variables i.e. export WALLET_ADDRESS='__FILL_ME__ MINING_POOLS='__FILL_ME__'
	@$(check_requirements) && ${run_with_docker}

stop-mining: ## Stop existing mining container
	@$(list_running_packetcrypt_rs-containers) | xargs -I{} docker rm -f {}

tail-logs: ## Tail running container logs
	@$(list_running_packetcrypt_rs-containers) | xargs -I{} docker logs -f {}

restart-mining: stop-mining start-mining tail-logs ## Stop and start mining container

push-docker-image: ## Tag and push docker image
	@docker tag packetcrypt_rs:latest thierrymarianne/packetcrypt_rs:develop && docker push thierrymarianne/packetcrypt_rs:develop

