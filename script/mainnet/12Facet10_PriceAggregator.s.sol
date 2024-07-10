// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSPriceAggregator} from "src/core/facets/GNSPriceAggregator.sol";

contract PriceAggregatorScript is BaseScriptDeployer{
    function run() public {
        GNSPriceAggregator priceAggregator = new GNSPriceAggregator();
        console2.log("priceAggregator ", address(priceAggregator));
    }
}