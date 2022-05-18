FROM rust:1.60.0-bullseye

ARG GITHUB_REPO=https://github.com/tonlabs/ton-labs-node-tools.git
ARG GITHUB_COMMIT_ID=master

RUN apt-get update && apt-get install -y libzstd-dev libssl-dev clang
ENV ZSTD_LIB_DIR=/usr/lib/x86_64-linux-gnu
RUN git clone --recurse-submodules ${GITHUB_REPO} ton-labs-node-tools \
    && cd ton-labs-node-tools \
    && git checkout ${GITHUB_COMMIT_ID} \
    && cargo build --release --bins

FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
        ca-certificates \
        libssl1.1 \
    && rm -fr /var/lib/apt/lists/*

COPY --from=0 \
    /ton-labs-node-tools/target/release/console \
    /ton-labs-node-tools/target/release/zerostate \
    /ton-labs-node-tools/target/release/keygen \
    /ton-labs-node-tools/target/release/gendht \
    /ton-labs-node-tools/target/release/dhtscan \
    /ton-labs-node-tools/target/release/print \
    /usr/bin/

