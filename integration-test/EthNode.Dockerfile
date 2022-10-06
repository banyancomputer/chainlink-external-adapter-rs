FROM ubuntu

RUN apt-get update && apt-get install -y bash curl jq git

RUN curl -L https://foundry.paradigm.xyz | bash
ENV PATH="/root/.foundry/bin:${PATH}"
RUN foundryup

WORKDIR /app

# copy in the contracts
RUN mkdir contracts
COPY ./contracts-for-testing ./contracts

# deploy your contracts to the testnet!
ARG MNEMONIC
ARG INFURA_KEY
ENV INFURA_URL="https://goerli.infura.io/v3/${INFURA_KEY}"
ENV DEPLOYMENT_GAS_LIMIT=8000000

# move into contracts directory
WORKDIR /app/contracts
RUN git init && \
    git add . && \
    git config user.email "silly@goose.com" && \
    git config user.name "sillygooooose" && \
    git commit -m "initial commit"

RUN forge install --no-git
RUN forge build

RUN forge create \
    --rpc-url=${INFURA_URL}\
    --mnemonic="${MNEMONIC}" \
    --gas-limit="${DEPLOYMENT_GAS_LIMIT}"\
    BlockTime && exit 1

RUN cat /app/BlockTime.address && exit 1

# fork goerli with it deployed :)
CMD anvil --fork-url ${INFURA_URL} -p 8545
