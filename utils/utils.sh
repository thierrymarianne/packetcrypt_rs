#!/bin/bash

export COMPOSE_PROJECT_NAME=packetcrypt_sonar

function ensure_network_are_customized() {
    if [ ! -e "./docker-compose.override.yaml" ];
    then
        echo 'Please copy docker-compose.override.yaml.dist to docker-compose.override.yaml in service-provisioning/containers'
        echo 'and customize its content if needed.'
        echo 'A network is required to run both sonarqube-server and sonar-scanner containers'
        return 1
    fi
}

function start_sonarqube_server() {
    if [ ! -e "./.env.local" ];
    then
        echo 'Please copy ./.env.local.dist to .env.local in the project root directory'
        echo 'Sonar URL, username and password and authentication token are needed'
        echo 'After running sonarqube server, follow this documentation to generate a token: '
        echo 'https://docs.sonarqube.org/latest/user-guide/user-token/'
        return 1
    fi

    cd service-provisioning/containers || exit

    ensure_network_are_customized

    docker ps -a | \
    grep packetcrypt_sonar | \
    awk '{print $1}' | \
    xargs -I{} docker rm -f {}

    docker-compose \
    -f ./docker-compose.yaml \
    -f ./docker-compose.override.yaml up sonarqube-server
}

function start_sonar_scanner() {
    if [ ! -e "./.env.local" ];
    then
        echo 'Please copy ./.env.local.dist to .env.local in the project root directory'
        echo 'Sonar URL, username and password and authentication token (SONAR_LOGIN) are needed'
        echo 'After running sonarqube server, follow this documentation to generate a token: '
        echo 'https://docs.sonarqube.org/latest/user-guide/user-token/'
        echo 'and this documentation to run SonarScanner'
        echo 'https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/'
        return 1
    fi

    cd service-provisioning/containers || exit

    cd ../volumes/sonarqube-extensions || exit
    mkdir plugins
    cd plugins || exit

    wget https://github.com/elegoff/sonar-rust/releases/download/v0.0.4/sonar-rust-plugin-0.0.4.jar \
    -O sonar-rust-plugin-0.0.4.jar

    cd ../../../containers || exit

    docker-compose \
    -f ./docker-compose.yaml \
    -f ./docker-compose.override.yaml run sonar-scanner \
    /usr/bin/entrypoint.sh sonar-scanner
}
