// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';

contract BlockTime is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 public averageBlockTimeInMicroseconds;

    // sure, this is the easy way to do it... but we're going to do it the hard way.
    //    function getAverageBlockTimeSince(u256 blockNumber) public view returns (u256) {
    //        u256 blockTime = u256(block.timestamp);
    //        u256 blockTimeSince = blockTime - u256(block.timestamp);
    //        return blockTimeSince / (block.number - blockNumber);
    //    }

    /**
     * @notice Initialize the link token and target oracle
     *
     * Goerli Testnet details:
     * Link Token: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Oracle: 0xCC79157eb46F5624204f47AB42b3906cAA40eaB7 (Chainlink DevRel)
     * jobId: ca98366cc7314957b8c012c72f05aeeb
     *
     */
    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        setChainlinkOracle(0xCC79157eb46F5624204f47AB42b3906cAA40eaB7);
        jobId = 'ca98366cc7314957b8c012c72f05aeeb';
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }


    function startComputeAverageBlockTimeSinceWithChainlink(uint256 blockNumber) public returns (uint256) {
        Chainlink.Request memory req = buildChainlinkRequest(SPEC_ID, this, this.fulfill.selector);
        req.addInt("block_num", blockNumber);
        return sendChainlinkRequest(req, oraclePayment);
    }

    function fulfill(bytes32 _requestId, uint256 _averageBlockTimeInMicroseconds) public recordChainlinkFulfillment(_requestId) {
        averageBlockTimeInMicroseconds = _averageBlockTimeInMicroseconds;
    }
}
