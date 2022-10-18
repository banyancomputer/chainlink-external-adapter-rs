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

# chainlink Node Setup

Follow the instructions to set up a chainlink EA Node on https://docs.chain.link/docs/running-a-chainlink-node/

Once you have set everything up, each time you start up your chainlink node again requires: 

Connect postgreSQl to workbench: sh sqlworkbench.sh
Pull desired docker image if not already present in docker: 
docker pull smartcontract/chainlink:1.7.0-root
Run: 
docker run -p 6688:6688 -v ~/.chainlink-goerli:/chainlink -it --env-file=.env smartcontract/chainlink:1.7.0-nonroot local n
Make sure your ip is permitted in inbound security group settings for AWS PostgreSql backend. Add your ip, which you can find with the command: 
dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com 

To launch the API on the localhost: Cargo run 

Create a chainlink job by copying the example_job.toml into the chainlink node operator UI. Create a bridge in the UI, specifying the name of the bridge in the job (.i.e. rust_proof_verifier), and make sure to specify that the url is a docker internal address: http://host.docker.internal:8000/compute

You must deploy the operator.sol contract using the deploy_operator function and call the set_authorized_senders fu

# contract deployment
Deploy contract using 
npx hardhat run scripts/deploy.js --network goerli
BlockTime.sol is a test contract. You can see our real contracts at https://github.com/banyancomputer/contracts. BlockTime.sol is deployed at 0xa8f4eD2ecE0CaF2fdCf1dA617f000D827b30ED19. 

Trigger chainlink API contract function for basic testing using 
npx hardhat run scripts/test_example_ea.js --network goerli 

Make sure your contract is funded with some testnet link

# testing

TODO. Look at unit testing framework in https://github.com/banyancomputer/chainlink-proof-validator/blob/jonahkaye/feat/unit_testing/src/main.rs
