// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const fs = require('fs');

async function main() {

  const BlockTime = await hre.ethers.getContractFactory("BlockTime"); // change to BlockTime if using the example contract. 
  const blocktime = await BlockTime.deploy();
  
  await blocktime.deployed();
  console.log("Proofs deployed to:", blocktime.address);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});