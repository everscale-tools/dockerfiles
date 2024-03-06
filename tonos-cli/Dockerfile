FROM rust:1.76-bookworm

ARG EVER_CLI_REPO_REF=master

RUN git clone --recurse-submodules https://github.com/tonlabs/ever-cli.git \
    && cd ever-cli \
    && git checkout $EVER_CLI_REPO_REF -b build \
    && cargo build --release

RUN git clone https://github.com/tonlabs/ton-labs-contracts.git

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl3 \
    ca-certificates

WORKDIR /usr/lib/ever-cli

ENV TONOSCLI_CONFIG=/usr/lib/ever-cli/tonos-cli.conf.json

COPY --from=0 /ever-cli/target/release/tonos-cli /usr/local/bin/
COPY --from=0 \
    /ton-labs-contracts/solidity/safemultisig/SafeMultisigWallet.abi.json \
    /ton-labs-contracts/solidity/safemultisig/SafeMultisigWallet.tvc \
    /ton-labs-contracts/solidity/setcodemultisig/SetcodeMultisigWallet.abi.json \
    /ton-labs-contracts/solidity/setcodemultisig/SetcodeMultisigWallet.tvc \
    /ton-labs-contracts/solidity/depool/DePool.abi.json \
    /ton-labs-contracts/solidity/depool/DePool.tvc \
    /ton-labs-contracts/solidity/depool/DePoolHelper.abi.json \
    /ton-labs-contracts/solidity/depool/DePoolHelper.tvc \
    /ton-labs-contracts/solidity/depool/DePoolProxy.abi.json \
    /ton-labs-contracts/solidity/depool/DePoolProxy.tvc \
    ./

ENTRYPOINT ["tonos-cli"]

