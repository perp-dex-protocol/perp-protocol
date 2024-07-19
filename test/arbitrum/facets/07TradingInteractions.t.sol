// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {BasicScriptTest} from "../BasicScriptTest.t.sol";
import {GNSTradingInteractions} from "src/core/facets/GNSTradingInteractions.sol";
import {ITradingStorage} from "src/interfaces/types/ITradingStorage.sol";

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
}

contract TradingInteractionsTest is BasicScriptTest {
    address diamondcontract = 0xFF162c694eAA571f685030649814282eA457f169;

    GNSTradingInteractions tradingContract = GNSTradingInteractions(diamondcontract);
    address Alice = makeAddr("Alice");

    address dai_address = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;

    // test open Trade
    function testTrade() public {
        vm.deal(Alice, 1 ether);
        deal(dai_address, Alice, 500 ether);
        console2.log(Alice.balance);

        vm.startPrank(Alice, Alice);
        IERC20(dai_address).approve(diamondcontract, 500 ether);

        // open trade native
        // ITradingStorage.Trade memory trade = ITradingStorage.Trade(
        //     Alice,
        //     0,
        //     109,
        //     40000,
        //     true,
        //     true,
        //     2,
        //     ITradingStorage.TradeType.TRADE,
        //     0.02 ether,
        //     0.760871e10,
        //     9320669750,
        //     0,
        //     0
        // );

        // tradingContract.openTradeNative{value: 0.02 ether}(trade, 1056, address(0));

        // open trade
        ITradingStorage.Trade memory trade = ITradingStorage.Trade(
            Alice,
            0,
            136,
            5000,
            true,
            true,
            1,
            ITradingStorage.TradeType.TRADE,
            400 ether,
            282170000000,
            790076000000,
            0,
            0
        );
        tradingContract.openTrade(trade, 1015, address(0));
        // tp take profit
        // sl stop loss
    }
}
