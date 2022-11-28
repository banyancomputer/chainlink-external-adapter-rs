# What is it?

This is a template Chainlink External Adaptor written in Rust. Chainlink External Adaptors are how you integrate custom off chain computations into your on-chain application. 

# What it does? 

It receives calls from a contract on-chain, makes calls to an API, does some example calculations, and returns values to chain. 

# initial setup
install deps
```bash
$ npm i
```

move .env.example to .env
```bash
$ mv .env.example .env
```
then add your private key and infura API key to .env

# PreReqs

Follow the instructions to set up a Chainlink External Adaptor Node on your local machine in a Docker https://docs.chain.link/docs/running-a-chainlink-node/

You will need to install Docker, Sqlworkbench, and set up and AWS postgreSQL database. The instructions linked above walk you through this. You will also need to install Hardhat: 
```bash
npm i hardhat
```

# Chainlink Node Setup

Once you have set everything up, each time you start up your Chainlink node again requires: 

Connect postgreSQl to workbench:
```bash
$ sh sqlworkbench.sh
```
Pull desired docker image if not already present in docker: 
```bash
$ docker pull smartcontract/chainlink:1.7.0-root
```
Run: 
```bash
$ docker run -p 6688:6688 -v ~/.chainlink-goerli:/chainlink -it --env-file=.env smartcontract/chainlink:1.7.0-nonroot local n
```
Make sure your ip is permitted in inbound security group settings for AWS PostgreSql backend. Add your ip, which you can find with the command: 
```bash
$ dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com 
```
To launch the API on the localhost: 
```bash
$ Cargo run 
```
Create a Chainlink job by copying the example_job.toml into the Chainlink node operator UI. Create a bridge in the UI, specifying the name of the bridge in the job (.i.e. rust_proof_verifier), and make sure to specify that the url is a docker internal address: http://host.docker.internal:8000/compute

You must deploy the operator.sol contract using the deploy_operator function and call the set_authorized_senders function. You can do by subsituting your own node address as the authorized sender when you call this script below
```bash 
$ npx hardhat run scripts/deploy_operator.js --network goerli
```

# contract deployment
Deploy contract using
```bash 
$ npx hardhat run scripts/deploy.js --network goerli
```
BlockTime.sol is a test contract. You can see our real contracts at https://github.com/banyancomputer/contracts. BlockTime.sol is deployed at 0xa8f4eD2ecE0CaF2fdCf1dA617f000D827b30ED19. 

Trigger Chainlink API contract function for basic testing using 
```bash
$ npx hardhat run scripts/test_example_ea.js --network goerli 
```
Make sure your contract is funded with some testnet link which you can get here https://faucets.chain.link/

# testing
To test run 
```bash
$ cargo test
```
Look at unit testing framework in to write tests specific to your application https://github.com/banyancomputer/chainlink-proof-validator/blob/main/src/main.rs 