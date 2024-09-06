// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {CopyTrade} from "src/core/facets/CopyTrade.sol";
import {ITradingStorage} from "src/interfaces/types/ITradingStorage.sol";
import {GNSTradingInteractions} from "src/core/facets/GNSTradingInteractions.sol";
import {GNSTradingStorage} from "src/core/facets/GNSTradingStorage.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract CopyTradeScript is BaseScriptDeployer {
    address bot_address = makeAddr("Bot");

    address public wsei_contract = 0xE30feDd158A2e3b13e9badaeABaFc5516e95e8C7;
    GNSTradingInteractions tradingInteraction =
        GNSTradingInteractions(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));
    GNSTradingStorage tradingStorage = GNSTradingStorage(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

    CopyTrade copyTrade;

    function run() public {
        copyTrade = new CopyTrade(bot_address);
        console2.log("copy trade contract address", address(copyTrade));

        // delegate trade
        address Alice = makeAddr("Alice");
        vm.deal(Alice, 1000 ether);
        vm.startPrank(Alice);
        address trader = makeAddr("Trader");
        copyTrade.delegateTrade{value: 100 ether}(trader);
        console2.log(IERC20(wsei_contract).balanceOf(address(copyTrade)));

        vm.stopPrank();
        // copy trade
        address copier = makeAddr("Copier");

        vm.startPrank(bot_address);
        ITradingStorage.Trade memory trade = ITradingStorage.Trade({
            user: address(copyTrade),
            index: 0,
            pairIndex: 0,
            leverage: 100000,
            long: true,
            isOpen: true,
            collateralIndex: 1,
            tradeType: ITradingStorage.TradeType.TRADE,
            collateralAmount: 3e18,
            openPrice: 3508e10,
            tp: 0,
            sl: 0,
            __placeholder: 0
        });

        copyTrade.copyTrade(Alice, trader, trade, 1010);

        getUserAllTrades(address(copyTrade));

        // close trade
        // copyTrade.closeTrade(trader);
        // console2.log(IERC20(wsei_contract).balanceOf(address(copyTrade)));
    }

    function getUserAllTrades(address user) public view {
        ITradingStorage.Trade[] memory trades = tradingStorage.getTrades(user);
        console2.log("user all trades length", trades.length);

        for (uint256 i = 0; i < trades.length; i++) {
            console2.log("====================================");
            console2.log(" trade user ", trades[i].user);
            console2.log(" trade index ", trades[i].index);
            console2.log(" trade pairIndex ", trades[i].pairIndex);
            console2.log(" trade leverage ", trades[i].leverage);
            console2.log(" trade long ", trades[i].long);
            console2.log(" trade isOpen ", trades[i].isOpen);
            console2.log(" trade collateralIndex ", trades[i].collateralIndex);
            console2.log(" trade tradeType ", uint256(trades[i].tradeType));
            console2.log(" trade collateralAmount ", trades[i].collateralAmount);
            console2.log(" trade openPrice ", trades[i].openPrice);
            console2.log(" trade tp ", trades[i].tp);
            console2.log(" trade sl ", trades[i].sl);
            console2.log(" trade __placeholder ", trades[i].__placeholder);
        }
    }
}
