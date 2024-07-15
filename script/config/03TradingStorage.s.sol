// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSTradingStorage} from "src/core/facets/GNSTradingStorage.sol";
import {ITradingStorage} from "src/interfaces/types/ITradingStorage.sol";

contract TradingStorageScript is BaseScriptDeployer {


     GNSTradingStorage tradingStorage = GNSTradingStorage(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));


    function run() public {
        tradingStorage.updateTradingActivated(ITradingStorage.TradingActivated.ACTIVATED);
    }
}
