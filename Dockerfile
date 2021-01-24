FROM debian:buster-slim AS builder

COPY --chown=10000:10001 . /packetcrypt/

# Update package source repositories
RUN apt update -y && \
# Add packetcrypt group
    groupadd -g 10001 packetcrypt && \
# Add packetcrypt_miner user
    useradd \
        -s /bin/bash -u 10000 \
        -g packetcrypt \
        --home /packetcrypt \
    packetcrypt_miner && \
    apk add --no-cache \
        tini \
        curl \
        gcc \
        git \
        file \
        build-base && \
# Install required packages
    apt install -y tini curl gcc git file build-essential && \
# Download rustup and install cargo
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile complete && \
# Build release
    cd /packetcrypt && ~/.cargo/bin/cargo build --release && \
    mv ./target/release/packetcrypt /usr/bin && \
# Remove packages installed with apt but preserve tini
    apt purge -y curl gcc git file build-essential && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
# Remove cargo
    rm -rf /root/.cargo && \
# Change permissions of packetcrypt directory
    chown -R packetcrypt_miner:packetcrypt /packetcrypt

FROM debian:buster-slim

WORKDIR /usr/bin

COPY --from=builder /usr/bin .

USER 10000:10001

ENTRYPOINT ["/usr/bin/tini", "--"]
