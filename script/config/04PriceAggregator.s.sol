// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSPriceAggregator} from "src/core/facets/GNSPriceAggregator.sol";
import {IChainlinkFeed} from "src/interfaces/IChainlinkFeed.sol";

contract PriceAggregatorScript is BaseScriptDeployer {
    GNSPriceAggregator priceAggregator = GNSPriceAggregator(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

    function run() public {
        // eth price
        priceAggregator.updateCollateralUsdPriceFeed(1, IChainlinkFeed(0x65bb746B987ccB004b004B6aC9Df18e9ccfca004));
    }
}
