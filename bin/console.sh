#!/bin/bash

export COMPOSE_PROJECT_NAME='packetcrypt_rs'

function check_environment_vars {
    if [ -z "$MINING_POOLS" ] || [ -z "$WALLET_ADDRESS" ];
    then
        echo "Your wallet address and mining pool are to be declared as environment variables e.g." && \
        echo "export WALLET_ADDRESS='"'"'__FILL_ME__'"'"' MINING_POOLS='"'"'__FILL_ME__'"'"'"
        return 1
    fi

    if [ -n "$MINING_POOLS" ] && [ -n "$WALLET_ADDRESS" ];
    then
        echo 'About to mine via "'"${MINING_POOLS}"'" on behalf of "'"${WALLET_ADDRESS}"'"'
    fi
}

function pull_docker_image {
    local run_with_docker_compose
    run_with_docker_compose='docker-compose '

    if [ -e docker-compose-test.override.yml ]
    then
        run_with_docker_compose='docker-compose -f docker-compose.yml -f docker-compose.override.yml '
    fi

    local command
    command="${run_with_docker_compose} pull"

    echo 'About to run: "' ${command}'"'
    /bin/bash -c "${command}"

    echo 'Digest of most recent image which name contains "thierrymarianne/packetcryptcypt_rs":'
    docker images | \
    grep 'thierrymarianne/packetcrypt_rs' | \
    awk '{print $3}' |  \
    head -n1 | \
    xargs -I{} docker inspect --format '{{.RepoDigests}}' {}
}

function check_requirements {
    check_environment_vars
    pull_docker_image
}
