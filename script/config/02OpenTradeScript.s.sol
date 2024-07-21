// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSTradingInteractions} from "src/core/facets/GNSTradingInteractions.sol";
import {GNSTradingStorage} from "src/core/facets/GNSTradingStorage.sol";
import {ITradingStorage} from "src/interfaces/types/ITradingStorage.sol";

interface IWSei {
    function deposit() external payable;
    function approve(address spender, uint256 amount) external returns (bool);
}

contract OpenTradingScript is BaseScriptDeployer {
    GNSTradingInteractions tradingInteraction =
        GNSTradingInteractions(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));
    GNSTradingStorage tradingStorage = GNSTradingStorage(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

    address user_address = 0x5557bc35b36f3d92Af1A1224b1e090f6Dd5b00CE;

    function run() public {
        // initializTrade();

        // 1. open order
        // openTrade();
        // openNativeTrade();

        // 2. cancelOrder trade
        // cancelOrder(0);

        // 3. closeOrder

        // 4. get Pending Order
        // getUserPendingOrders(user_address);
        // getAllPendingorder();
    }

    function initializTrade() public {
        address[] memory usersByPassTriggerLink = new address[](1);
        usersByPassTriggerLink[0] = user_address;

        tradingInteraction.initializeTrading(200, usersByPassTriggerLink);
    }

    function approveToekn() public {
        IWSei(0xE30feDd158A2e3b13e9badaeABaFc5516e95e8C7).deposit{value: 3e18}();
        IWSei(0xE30feDd158A2e3b13e9badaeABaFc5516e95e8C7).approve(address(tradingInteraction), 100 ether);
    }

    function openTrade() public {
        ITradingStorage.Trade memory trade = ITradingStorage.Trade({
            user: user_address,
            index: 0,
            pairIndex: 0,
            leverage: 100000,
            long: true,
            isOpen: true,
            collateralIndex: 1,
            tradeType: ITradingStorage.TradeType.TRADE,
            collateralAmount: 3e18,
            openPrice: 3508e8,
            tp: 0,
            sl: 0,
            __placeholder: 0
        });

        tradingInteraction.openTrade(trade, 1, address(0));
    }

    function openNativeTrade() public {
        ITradingStorage.Trade memory trade = ITradingStorage.Trade({
            user: user_address,
            index: 0,
            pairIndex: 0,
            leverage: 100000,
            long: true,
            isOpen: true,
            collateralIndex: 1,
            tradeType: ITradingStorage.TradeType.TRADE,
            collateralAmount: 3e18,
            openPrice: 3508e8,
            tp: 0,
            sl: 0,
            __placeholder: 0
        });

        tradingInteraction.openTradeNative{value: 3 ether}(trade, 1, address(0));
    }

    function cancelOrder(uint32 index) public {
        tradingInteraction.cancelOpenOrder(0);
    }

    function triggerOrder() public {}

    function getUserPendingOrders(address userAddress) public {
        ITradingStorage.PendingOrder[] memory pendingOrders = tradingStorage.getPendingOrders(userAddress);

        console2.log(pendingOrders.length);
        for (uint256 i = 0; i < pendingOrders.length; i++) {
            console2.log("====================================");

            console2.log(" trade user ", pendingOrders[i].trade.user);
            console2.log(" trade index ", pendingOrders[i].trade.index);
            console2.log(" trade pairIndex ", pendingOrders[i].trade.pairIndex);
            console2.log(" trade leverage ", pendingOrders[i].trade.leverage);
            console2.log(" trade long ", pendingOrders[i].trade.long);
            console2.log(" trade isOpen ", pendingOrders[i].trade.isOpen);
            console2.log(" trade collateralIndex ", pendingOrders[i].trade.collateralIndex);
            console2.log(" trade tradeType ", uint256(pendingOrders[i].trade.tradeType));
            console2.log(" trade collateralAmount ", pendingOrders[i].trade.collateralAmount);
            console2.log(" trade openPrice ", pendingOrders[i].trade.openPrice);
            console2.log(" trade tp ", pendingOrders[i].trade.tp);
            console2.log(" trade sl ", pendingOrders[i].trade.sl);
            console2.log(" trade __placeholder ", pendingOrders[i].trade.__placeholder);
            console2.log(" user ", pendingOrders[i].user);
            console2.log(" index ", pendingOrders[i].index);
            console2.log(" isOpen ", pendingOrders[i].isOpen);
            console2.log(" orderType ", uint256(pendingOrders[i].orderType));
            console2.log(" createdBlock ", pendingOrders[i].createdBlock);
            console2.log(" maxSlippageP ", pendingOrders[i].maxSlippageP);
        }

        //  struct PendingOrder {
        // // slots 1-3
        // Trade trade;
        // // slot 4
        // address user; // 160 bits
        // uint32 index; // max: 4,294,967,295
        // bool isOpen; // 8 bits
        // PendingOrderType orderType; // 8 bits
        // uint32 createdBlock; // max: 4,294,967,295
        // uint16 maxSlippageP; // 1e3 (%), max: 65.535%
    }

    function getAllPendingorder() public {
        ITradingStorage.PendingOrder[] memory pendingOrders = tradingStorage.getAllPendingOrders(0, 3);

        console2.log(pendingOrders.length);
        for (uint256 i = 0; i < pendingOrders.length; i++) {
            console2.log("====================================");

            console2.log(" trade user ", pendingOrders[i].trade.user);
            console2.log(" trade index ", pendingOrders[i].trade.index);
            console2.log(" trade pairIndex ", pendingOrders[i].trade.pairIndex);
            console2.log(" trade leverage ", pendingOrders[i].trade.leverage);
            console2.log(" trade long ", pendingOrders[i].trade.long);
            console2.log(" trade isOpen ", pendingOrders[i].trade.isOpen);
            console2.log(" trade collateralIndex ", pendingOrders[i].trade.collateralIndex);
            console2.log(" trade tradeType ", uint256(pendingOrders[i].trade.tradeType));
            console2.log(" trade collateralAmount ", pendingOrders[i].trade.collateralAmount);
            console2.log(" trade openPrice ", pendingOrders[i].trade.openPrice);
            console2.log(" trade tp ", pendingOrders[i].trade.tp);
            console2.log(" trade sl ", pendingOrders[i].trade.sl);
            console2.log(" trade __placeholder ", pendingOrders[i].trade.__placeholder);
            console2.log(" user ", pendingOrders[i].user);
            console2.log(" index ", pendingOrders[i].index);
            console2.log(" isOpen ", pendingOrders[i].isOpen);
            console2.log(" orderType ", uint256(pendingOrders[i].orderType));
            console2.log(" createdBlock ", pendingOrders[i].createdBlock);
            console2.log(" maxSlippageP ", pendingOrders[i].maxSlippageP);
        }
    }

    function packTriggerOrder(uint8 orderType, address trader, uint32 index) external pure returns (uint256 packed) {
        packed = uint256(orderType) | (uint256(uint160(trader)) << 8) | (uint256(index) << 168);
    }
}
