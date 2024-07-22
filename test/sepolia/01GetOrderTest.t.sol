// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {GNSTradingStorage} from "src/core/facets/GNSTradingStorage.sol";
import {ITradingStorage} from "src/interfaces/types/ITradingStorage.sol";

contract OrderStatusTest is Test {
    GNSTradingStorage tradingStorage = GNSTradingStorage(payable(0xd659a15812064C79E189fd950A189b15c75d3186));
    address user_address = 0x7d6e74D0C1298Cb8A5DF19EA8899a9A73E46c241;

    function setUp() public {
        vm.createSelectFork("https://sepolia-rollup.arbitrum.io/rpc", 65731121);
    }

    function testGetUserOrders() public {
        console2.log(block.number);

        getUserCounters();

        getUserPendingOrders(user_address);

        getUserAllTradesInfos(user_address);
    }

    // Sepolia
    // 1. openTrade             https://sepolia.arbiscan.io/tx/0x05766a86d4adef0e8efed687e945650debcae52bc91f73602aa2cdfb1f581af8       65731120
    // 2. openTradeCallback     https://sepolia.arbiscan.io/tx/0xde00bf686e6dc6659775db00492e855542c12dcc819a8d7eac67ab5ab0dbb141       65731126

    // Arbitrum 
    // 1. openTrade             https://app.blocksec.com/explorer/tx/arbitrum/0xdd9fa73788888fd8839a56d919139b2a78429be1407c8be913abe9e208dd86ca
    // 2. openTradeCallBack     https://app.blocksec.com/explorer/tx/arbitrum/0x56545447f5f12340d513b874ee7484d5d4ef83b706af1bc2d2e1efd847032063
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

    function getUserAllTradesInfos(address user) public {
        ITradingStorage.TradeInfo[] memory allTrades = tradingStorage.getTradeInfos(user);
        console2.log(allTrades.length);

        for (uint256 i = 0; i < allTrades.length; i++) {
            console2.log("====================================");
            console2.log(" createdBlock ", allTrades[i].createdBlock);
            console2.log(" tpLastUpdatedBlock ", allTrades[i].tpLastUpdatedBlock);
            console2.log(" slLastUpdatedBlock ", allTrades[i].slLastUpdatedBlock);
            console2.log(" maxSlippageP ", allTrades[i].maxSlippageP);
            console2.log(" lastOiUpdateTs ", allTrades[i].lastOiUpdateTs);
            console2.log(" collateralPriceUsd ", allTrades[i].collateralPriceUsd);
            console2.log(" __placeholder ", allTrades[i].__placeholder);
        }
    }
}
