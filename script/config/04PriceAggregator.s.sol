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
        priceAggregator.updateCollateralUsdPriceFeed(1, IChainlinkFeed(0xEFc092F9D1Fd756D6788C5E8c1043Ed7a7F423Df));
    }
}
