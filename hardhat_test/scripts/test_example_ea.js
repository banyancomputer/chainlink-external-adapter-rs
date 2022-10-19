const hre = require("hardhat");
const {Buffer} = require('node:buffer');
const fs = require('fs');
const {TextEncoder} = require("util");
const { exit } = require("node:process");

async function main() {
  
  const Test = await ethers.getContractFactory("BlockTime");
  const test = await Test.attach("0xa8f4eD2ecE0CaF2fdCf1dA617f000D827b30ED19"); // change this based on your contract adddress
  console.log(test.address);

  let jobId = 'a66c9947b4d94331ae8fd445265bf430';
  const transactionResponse_2 = await test.startComputeTimeSinceWithChainlink(0,jobId);
  const transactionReceipt_2 = await transactionResponse_2.wait(); 
  console.log(transactionResponse_2)
  

  const transactionResponse3 = await test.timeSince();
  console.log("Time Since:", transactionResponse3);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });