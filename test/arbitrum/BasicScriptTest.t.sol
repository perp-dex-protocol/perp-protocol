// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";

contract BasicScriptTest is Test {
    function setUp() public {
        // vm.createSelectFork("https://arbitrum.llamarpc.com");
        vm.createSelectFork("https://arb-mainnet.g.alchemy.com/v2/HbWp0T6O7ZJKhm68Aimx_bNIFS1yLrDv");
    }
}
