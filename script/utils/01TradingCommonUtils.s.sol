// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {TradingCommonUtils} from "src/libraries/TradingCommonUtils.sol";

contract UtilsScript is BaseScriptDeployer {
    function run() public {
        // TradingCommonUtils tradingCommonUtils = new TradingCommonUtils();
    }
}
