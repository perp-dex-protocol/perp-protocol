// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";

contract BaseScriptDeployer is Script {
    function setUp() public {
        vm.createSelectFork("https://evm-rpc.sei-apis.com");
        uint256 deployerPrivateKey = vm.envUint("PRI_KEY");
        vm.startBroadcast(deployerPrivateKey);
    }
}
