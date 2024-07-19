// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSTradingInteractions} from "src/core/facets/GNSTradingInteractions.sol";
import {ITradingStorage} from "src/interfaces/types/ITradingStorage.sol";

contract OpenTradingScript is BaseScriptDeployer {
    GNSTradingInteractions tradingInteraction =
        GNSTradingInteractions(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

    address user_address = 0x5557bc35b36f3d92Af1A1224b1e090f6Dd5b00CE;

    function run() public {
        // initializTrade();

        openTrade();
    }

    function initializTrade() public {
        address[] memory usersByPassTriggerLink = new address[](1);
        usersByPassTriggerLink[0] = user_address;

        tradingInteraction.initializeTrading(200, usersByPassTriggerLink);
    }

    // struct Trade {
    // slot 1
    //     address user; // 160 bits
    //     uint32 index; // max: 4,294,967,295
    //     uint16 pairIndex; // max: 65,535
    //     uint24 leverage; // 1e3; max: 16,777.215
    //     bool long; // 8 bits
    //     bool isOpen; // 8 bits
    //     uint8 collateralIndex; // max: 255
    //     // slot 2
    //     TradeType tradeType; // 8 bits
    //     uint120 collateralAmount; // 1e18; max: 3.402e+38
    //     uint64 openPrice; // 1e10; max: 1.8e19
    //     uint64 tp; // 1e10; max: 1.8e19
    //     // slot 3 (192 bits left)
    //     uint64 sl; // 1e10; max: 1.8e19
    //     uint192 __placeholder;
    // }

    function openTrade() public {
        ITradingStorage.Trade memory trade = ITradingStorage.Trade({
            user: user_address,
            index: 0,
            pairIndex: 0,
            leverage: 10000,
            long: true,
            isOpen: true,
            collateralIndex: 1,
            tradeType: ITradingStorage.TradeType.TRADE,
            collateralAmount: 100e18,
            openPrice: 10000000000,
            tp: 10000000000,
            sl: 0,
            __placeholder: 0
        });

        tradingInteraction.openTrade(trade, 1, address(0));
    }
}
