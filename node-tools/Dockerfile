FROM rust:1.76.0-bullseye

ARG GITHUB_COMMIT_ID=master

RUN apt-get update && apt-get install -y clang libzstd-dev libgoogle-perftools-dev
ENV ZSTD_LIB_DIR=/usr/lib/x86_64-linux-gnu
RUN git clone --recurse-submodules https://github.com/tonlabs/ton-labs-node.git \
    && cd ton-labs-node \
    && git checkout ${GITHUB_COMMIT_ID} \
    && cargo build --release --bins

FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
        ca-certificates \
        libssl1.1 \
    && rm -fr /var/lib/apt/lists/*

COPY --from=0 \
    /ton-labs-node/target/release/console \
    /ton-labs-node/target/release/zerostate \
    /ton-labs-node/target/release/keygen \
    /ton-labs-node/target/release/gendht \
    /ton-labs-node/target/release/dhtscan \
    /ton-labs-node/target/release/print \
    /usr/bin/

