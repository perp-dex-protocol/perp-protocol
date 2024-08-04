// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSTradingInteractions} from "src/core/facets/GNSTradingInteractions.sol";
import {GNSTradingStorage} from "src/core/facets/GNSTradingStorage.sol";
import {GNSBorrowingFees} from "src/core/facets/GNSBorrowingFees.sol";
import {ITradingStorage} from "src/interfaces/types/ITradingStorage.sol";

interface IWSei {
    function deposit() external payable;
    function approve(address spender, uint256 amount) external returns (bool);
}

contract OpenTradingScript is BaseScriptDeployer {
    GNSTradingInteractions tradingInteraction =
        GNSTradingInteractions(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));
    GNSTradingStorage tradingStorage = GNSTradingStorage(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

    GNSBorrowingFees borrowingFees = GNSBorrowingFees(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

    address user_address = 0x5557bc35b36f3d92Af1A1224b1e090f6Dd5b00CE;

    function run() public {
        // initializTrade();

        // 1. open market order
        // openTrade();
        // openNativeTrade();

        // 2. close market trade
        // closeOrder(14);

        // 3. open limit order
        // openLimitOrder();

        // 4. close limit order
        // closeLimitOrder(8);

        // 5. trigger order
        // uint256 packed = packTriggerOrder(2, user_address, 8);
        // triggerOrder(packed);

        // 6. decrease Pos
        // decreasePos();

        // 6. get Pending Order
        // getUserPendingOrders(user_address);
        // getAllPendingorder();

        // 8. close Pending order
        // closePendingOrder(0);


        // 9. updateLeverage
        // updateLeverage();


        // getUserAllTrades(user_address);

        // 10. increase pos data
        // increasePosData();

        // 11. decreasePos
        decreasePos() ;

        // 6. get trades
        getUserAllTrades(user_address);

        // 7. get User Counters
        // getUserCounters();

        // 8. get Oi info
        // getPairOi();

        // getPairOis();
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

    // openprice decimal 1e10
    // take profit decimal 1e10

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
            leverage: 130000,
            long: true,
            isOpen: true,
            collateralIndex: 1,
            tradeType: ITradingStorage.TradeType.TRADE,
            collateralAmount: 3e18,
            openPrice: 2900e10,
            tp: 0,
            sl: 0,
            __placeholder: 0
        });

        tradingInteraction.openTradeNative{value: 3 ether}(trade, 1003, address(0));
    }

    function openLimitOrder() public {
        ITradingStorage.Trade memory trade = ITradingStorage.Trade({
            user: user_address,
            index: 0,
            pairIndex: 0,
            leverage: 130000,
            long: false,
            isOpen: true,
            collateralIndex: 1,
            tradeType: ITradingStorage.TradeType.LIMIT,
            collateralAmount: 3.5e18,
            openPrice: 3379e10,
            tp: 0,
            sl: 0,
            __placeholder: 0
        });

        tradingInteraction.openTrade(trade, 1005, address(0));
    }

    function closeLimitOrder(uint32 id) public {
        tradingInteraction.cancelOpenOrder(id);
    }

    function cancelOrder(uint32 index) public {
        tradingInteraction.cancelOpenOrder(0);
    }

    function closeOrder(uint32 index) public {
        tradingInteraction.closeTradeMarket(index);
    }

    function triggerOrder(uint256 packdata) public {
        tradingInteraction.triggerOrder(packdata);
    }

    function closePendingOrder(uint32 index) public {
        tradingInteraction.cancelOrderAfterTimeout(index);
    }

    function increasePosData() public {
        tradingInteraction.increasePositionSize(14, 1e18, 135000, 2910e8, 1005);
    }

    function decreasePos() public {
        tradingInteraction.decreasePositionSize(14, 1e18, 0);
    }


    function updateLeverage() public {
        tradingInteraction.updateLeverage(14, 135000);
    }

    function getTrade() public {
        ITradingStorage.Trade memory trade = tradingStorage.getTrade(user_address, 0);

        console2.log("====================================");

        console2.log(" trade user ", trade.user);
        console2.log(" trade index ", trade.index);
        console2.log(" trade pairIndex ", trade.pairIndex);
        console2.log(" trade leverage ", trade.leverage);
        console2.log(" trade long ", trade.long);
        console2.log(" trade isOpen ", trade.isOpen);
        console2.log(" trade collateralIndex ", trade.collateralIndex);
        console2.log(" trade tradeType ", uint256(trade.tradeType));
        console2.log(" trade collateralAmount ", trade.collateralAmount);
        console2.log(" trade openPrice ", trade.openPrice);
        console2.log(" trade tp ", trade.tp);
        console2.log(" trade sl ", trade.sl);
        console2.log(" trade __placeholder ", trade.__placeholder);
    }

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
    }

    function getAllPendingorder() public {
        ITradingStorage.PendingOrder[] memory pendingOrders = tradingStorage.getAllPendingOrders(0, 1);

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

    function getUserAllTrades(address user) public {
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

    function getUserCounters() public {
        ITradingStorage.Counter memory pendingCount =
            tradingStorage.getCounters(user_address, ITradingStorage.CounterType.PENDING_ORDER);

        console2.log(" currentIndex ", pendingCount.currentIndex);
        console2.log(" openCount ", pendingCount.openCount);
        console2.log(" __placeholder ", pendingCount.__placeholder);
        console2.log("====================================");

        ITradingStorage.Counter memory tradeCount =
            tradingStorage.getCounters(user_address, ITradingStorage.CounterType.TRADE);
        console2.log(" currentIndex ", tradeCount.currentIndex);
        console2.log(" openCount ", tradeCount.openCount);
        console2.log(" __placeholder ", tradeCount.__placeholder);
    }

    function getPairOi() public {
        uint256 pairoi = borrowingFees.getPairOiCollateral(1, 0, true);
        console2.log("ETH pairor ", pairoi);
    }

    function getPairOis() public{
        (uint256 longOi, uint256 shortOi) = borrowingFees.getPairOisCollateral(1, 0);
        console2.log("ETH longOi ", longOi);
        console2.log("ETH shortOi ", shortOi);
    }

    function packTriggerOrder(uint8 orderType, address trader, uint32 index) internal pure returns (uint256 packed) {
        packed = uint256(orderType) | (uint256(uint160(trader)) << 8) | (uint256(index) << 168);
    }
}
