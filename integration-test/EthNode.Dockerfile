# todo busybox eventually
FROM ubuntu:latest

# RUN apk add --no-cache bash curl jq
# change shell to bash
SHELL ["/bin/bash", "-c"]

# install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    && rm -rf /var/lib/apt/lists/*

# install forge
RUN curl -L https://foundry.paradigm.xyz | bash
RUN source /root/.bashrc
ENV PATH="/root/.foundry/bin:${PATH}"

# add /root/.foundry/bin to PATH
RUN foundryup

WORKDIR /app

# copy in the contracts
RUN mkdir chainlink-ext-adapter
COPY . chainlink-ext-adapter

#RUN ls contracts && exit 1

# deploy your contracts to the chain
ARG MNEMONIC
ARG INFURA_KEY
ENV INFURA_URL = "https://mainnet.infura.io/v3/${INFURA_KEY}"

# move into contracts directory
WORKDIR /app/chainlink-ext-adapter/contracts-for-testing

RUN forge install --no-git

RUN forge create \
    --rpc-url="${INFURA_URL}" \
    --mnemonic="${MNEMONIC}" \
    contracts/src/BlockTime.sol:BlockTime

# fork mainnet
RUN anvil --fork-url ${INFURA_URL} -p 8545
