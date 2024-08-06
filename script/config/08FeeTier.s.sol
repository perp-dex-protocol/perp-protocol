// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSFeeTiers} from "src/core/facets/GNSFeeTiers.sol";

contract FeeTierScript is BaseScriptDeployer {
    GNSFeeTiers feeTiers = GNSFeeTiers(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

    function run() public {
        uint256 count = feeTiers.getFeeTiersCount();
        console2.log(count);
    }
}
