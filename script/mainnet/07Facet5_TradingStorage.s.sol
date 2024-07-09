// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSTradingStorage} from "src/core/facets/GNSTradingStorage.sol";

contract TradingStorageScript is BaseScriptDeployer {
    function run() public {
        GNSTradingStorage tradingStorage = new GNSTradingStorage();
        console2.log("tradingStorage  ", address(tradingStorage));
    }
}
