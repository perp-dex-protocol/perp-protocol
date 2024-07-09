// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSPriceImpact} from "src/core/facets/GNSPriceImpact.sol";

contract PriceImpactScript is Script {
    function setUp() public {
        vm.createSelectFork("https://evm-rpc.sei-apis.com");
        uint256 deployerPrivateKey = vm.envUint("PRI_KEY");
        vm.startBroadcast(deployerPrivateKey);
    }

    function run() public {
        GNSPriceImpact priceImpact = new GNSPriceImpact();
        console2.log("priceImpact  ", address(priceImpact));
    }
}
