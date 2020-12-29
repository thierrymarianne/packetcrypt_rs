#!/bin/bash

function check_envvars() {
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

