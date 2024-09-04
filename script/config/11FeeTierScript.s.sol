// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSFeeTiers} from "src/core/facets/GNSFeeTiers.sol";
import {IFeeTiersUtils} from "src/interfaces/libraries/IFeeTiersUtils.sol";

contract FeeTierScript is BaseScriptDeployer {
    GNSFeeTiers feetiers = GNSFeeTiers(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

    address user_address = 0x5557bc35b36f3d92Af1A1224b1e090f6Dd5b00CE;

    function run() public view {
        IFeeTiersUtils.TraderInfo memory traderInfo = feetiers.getFeeTiersTraderInfo(user_address);
        console2.log(traderInfo.lastDayUpdated);
        console2.log(traderInfo.trailingPoints);
    }
}
