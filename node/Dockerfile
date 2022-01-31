ARG GC_TON_NODE=master

FROM rust:1.58.0-bullseye

ARG GC_TON_NODE

WORKDIR /usr/src

RUN apt-get update && apt-get install -y clang libzstd-dev libgoogle-perftools-dev
ENV ZSTD_LIB_DIR=/usr/lib/x86_64-linux-gnu
RUN git clone --recurse-submodules https://github.com/tonlabs/ton-labs-node.git \
    && cd ton-labs-node \
    && git checkout -b build ${GC_TON_NODE} \
    && sed -i 's/127\.0\.0\.1/0.0.0.0/g' src/config.rs \
    && sed -i -E 's/log = "(.+)"/log = { version = "\1", features = ["release_max_level_off"] }/g' Cargo.toml \
    && cargo update \
    && cargo build --release
RUN git clone --recurse-submodules https://github.com/tonlabs/ton-labs-node-tools.git \
    && cd ton-labs-node-tools \
    && cargo update \
    && cargo build --release

FROM debian:bullseye-slim

ARG GC_TON_NODE

ENV GC_TON_NODE=${GC_TON_NODE}

COPY --from=0 \
    /usr/src/ton-labs-node/target/release/ton_node \
    /usr/src/ton-labs-node-tools/target/release/console \
    /usr/src/ton-labs-node-tools/target/release/zerostate \
    /usr/src/ton-labs-node-tools/target/release/gendht \
    /usr/src/ton-labs-node-tools/target/release/keygen \
    /usr/src/ton-labs-node-tools/target/release/dhtscan \
    /usr/src/ton-labs-node-tools/target/release/print \
    /usr/local/bin/

RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl1.1 \
    libgoogle-perftools4 \
    curl \
    jq

WORKDIR /etc/ton

COPY log_cfg.yml default_config.json ./
COPY entrypoint.sh /

ENTRYPOINT /entrypoint.sh

