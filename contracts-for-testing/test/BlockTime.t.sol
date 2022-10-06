// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BlockTime.sol";

// setting the chainlink oracle address here
address constant CHAINLINK_ORACLE = 0xCC79157eb46F5624204f47AB42b3906cAA40eaB7;

contract BlockTimeTest is Test {
    BlockTime blockTime;

    function setUp() public {
        blockTime = new BlockTime();
        blockTime.startComputeTimeSinceWithChainlink(0);
        // wait until fulfill gets called- if it doesn't happen in a minute, fail
        vm.roll(5*12);
        vm.startPrank(CHAINLINK_ORACLE);
        blockTime.fulfill(0, 10000);
        vm.stopPrank();
        vm.roll(5*12);
        if (blockTime.timeSince() == 0) {
            revert("blockTime.timeSince() == 0");
        }
    }

    function testChainlink() public view {
        assert(blockTime.timeSince() > 8000);
        assert(blockTime.timeSince() < 15000);
    }
}
