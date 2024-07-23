// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSPriceImpact} from "src/core/facets/GNSPriceImpact.sol";

contract PriceImpactScript is BaseScriptDeployer {
    function run() public {
        GNSPriceImpact priceImpact = GNSPriceImpact(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

        priceImpact.initializePriceImpact(7200, 3);

        // priceImpact.setPriceImpactWindowsCount(3);
        // priceImpact.setPriceImpactWindowsDuration(7200);
    }
}
