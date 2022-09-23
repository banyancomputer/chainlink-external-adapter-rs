// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import { BlockTime } from "../src/BlockTime.sol";

contract BlockTimeDeployScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        BlockTime blocktime = new BlockTime();
        vm.stopBroadcast();
    }

}
