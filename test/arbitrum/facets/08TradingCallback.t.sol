// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {BasicScriptTest} from "../BasicScriptTest.t.sol";
import {GNSTradingCallbacks} from "src/core/facets/GNSTradingCallbacks.sol";

contract TradingCallbacksTest is BasicScriptTest {
    address diamondcontract = 0xFF162c694eAA571f685030649814282eA457f169;
    GNSTradingCallbacks callback = GNSTradingCallbacks(diamondcontract);

    function testTradingCallback() public view {
        uint8 closeFee = callback.getVaultClosingFeeP();
        console2.log("Close Fee: ", closeFee);
    }
}
