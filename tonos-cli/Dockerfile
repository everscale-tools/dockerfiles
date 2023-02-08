FROM rust:1.66.0-bullseye

ARG TONOS_CLI_VERSION
ENV TONOS_CLI_REPO_REF=${TONOS_CLI_VERSION:+tags/v$TONOS_CLI_VERSION}
ENV TONOS_CLI_REPO_REF=${TONOS_CLI_REPO_REF:-master}

RUN git clone --recurse-submodules https://github.com/tonlabs/tonos-cli.git \
    && cd tonos-cli \
    && git checkout $TONOS_CLI_REPO_REF -b build \
    && cargo build --release

RUN git clone https://github.com/tonlabs/ton-labs-contracts.git

FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl1.1 \
    ca-certificates

WORKDIR /usr/lib/tonos-cli

COPY --from=0 /tonos-cli/target/release/tonos-cli /usr/local/bin/
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

