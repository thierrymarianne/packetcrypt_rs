FROM debian:buster

RUN apt update -y && apt install -y curl gcc git file build-essential && \
    groupadd -g 1000 packetcrypt && \
    useradd -s /bin/bash -u 1000 -g packetcrypt --home /packetcrypt packetcrypt_miner

COPY --chown=packetcrypt_miner:packetcrypt . /packetcrypt/

WORKDIR /packetcrypt

USER packetcrypt_miner:packetcrypt

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile complete && \
    ~/.cargo/bin/cargo build --release

USER root

RUN apt purge -y curl gcc git file build-essential

USER packetcrypt_miner:packetcrypt

CMD ["tail", "-f", "/dev/null"]