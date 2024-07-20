// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {BasicScriptTest} from "../BasicScriptTest.t.sol";
import {GNSPairsStorage} from "src/core/facets/GNSPairsStorage.sol";
import {IPairsStorage} from "src/interfaces/types/IPairsStorage.sol";

contract PairStorageTest is BasicScriptTest {
    address diamondcontract = 0xFF162c694eAA571f685030649814282eA457f169;
    GNSPairsStorage pairsStorage = GNSPairsStorage(diamondcontract);

    // function testGetFeesCount() public view {
    //     uint256 count = pairsStorage.feesCount();
    //     console2.log("Fees count: %d", count);
    // }

    function testGetFees() public view {
        // IPairsStorage.Fee memory fee0 = pairsStorage.fees(0);
        // console2.log("Fee name: %s", fee0.name);
        // console2.log("Open Fee: %d", fee0.openFeeP);
        // console2.log("Close Fee: %d", fee0.closeFeeP);
        // console2.log("Oracle Fee: %d", fee0.oracleFeeP);
        // console2.log("Trigger Order Fee: %d", fee0.triggerOrderFeeP);
        // console2.log("minPositionSizeUsd ", fee0.minPositionSizeUsd);

        // console2.log("==================================");
        // IPairsStorage.Fee memory fee1 = pairsStorage.fees(1);
        // console2.log("Fee name: %s", fee1.name);
        // console2.log("Open Fee: %d", fee1.openFeeP);
        // console2.log("Close Fee: %d", fee1.closeFeeP);
        // console2.log("Oracle Fee: %d", fee1.oracleFeeP);
        // console2.log("Trigger Order Fee: %d", fee1.triggerOrderFeeP);
        // console2.log("minPositionSizeUsd ", fee1.minPositionSizeUsd);

        // console2.log("==================================");
        // IPairsStorage.Fee memory fee2 = pairsStorage.fees(2);
        // console2.log("Fee name: %s", fee2.name);
        // console2.log("Open Fee: %d", fee2.openFeeP);
        // console2.log("Close Fee: %d", fee2.closeFeeP);
        // console2.log("Oracle Fee: %d", fee2.oracleFeeP);
        // console2.log("Trigger Order Fee: %d", fee2.triggerOrderFeeP);
        // console2.log("minPositionSizeUsd ", fee2.minPositionSizeUsd);

        // console2.log("==================================");
        // IPairsStorage.Fee memory fee3 = pairsStorage.fees(3);
        // console2.log("Fee name: %s", fee3.name);
        // console2.log("Open Fee: %d", fee3.openFeeP);
        // console2.log("Close Fee: %d", fee3.closeFeeP);
        // console2.log("Oracle Fee: %d", fee3.oracleFeeP);
        // console2.log("Trigger Order Fee: %d", fee3.triggerOrderFeeP);
        // console2.log("minPositionSizeUsd ", fee3.minPositionSizeUsd);

        // console2.log("==================================");
        // IPairsStorage.Fee memory fee4 = pairsStorage.fees(4);
        // console2.log("Fee name: %s", fee4.name);
        // console2.log("Open Fee: %d", fee4.openFeeP);
        // console2.log("Close Fee: %d", fee4.closeFeeP);
        // console2.log("Oracle Fee: %d", fee4.oracleFeeP);
        // console2.log("Trigger Order Fee: %d", fee4.triggerOrderFeeP);
        // console2.log("minPositionSizeUsd ", fee4.minPositionSizeUsd);

        // console2.log("==================================");
        // IPairsStorage.Fee memory fee5 = pairsStorage.fees(5);
        // console2.log("Fee name: %s", fee5.name);
        // console2.log("Open Fee: %d", fee5.openFeeP);
        // console2.log("Close Fee: %d", fee5.closeFeeP);
        // console2.log("Oracle Fee: %d", fee5.oracleFeeP);
        // console2.log("Trigger Order Fee: %d", fee5.triggerOrderFeeP);
        // console2.log("minPositionSizeUsd ", fee5.minPositionSizeUsd);

        // console2.log("==================================");
        // IPairsStorage.Fee memory fee6 = pairsStorage.fees(6);
        // console2.log("Fee name: %s", fee6.name);
        // console2.log("Open Fee: %d", fee6.openFeeP);
        // console2.log("Close Fee: %d", fee6.closeFeeP);
        // console2.log("Oracle Fee: %d", fee6.oracleFeeP);
        // console2.log("Trigger Order Fee: %d", fee6.triggerOrderFeeP);
        // console2.log("minPositionSizeUsd ", fee6.minPositionSizeUsd);

        // console2.log("==================================");
        // IPairsStorage.Fee memory fee7 = pairsStorage.fees(7);
        // console2.log("Fee name: %s", fee7.name);
        // console2.log("Open Fee: %d", fee7.openFeeP);
        // console2.log("Close Fee: %d", fee7.closeFeeP);
        // console2.log("Oracle Fee: %d", fee7.oracleFeeP);
        // console2.log("Trigger Order Fee: %d", fee7.triggerOrderFeeP);
        // console2.log("minPositionSizeUsd ", fee7.minPositionSizeUsd);

        // console2.log("==================================");
        // IPairsStorage.Fee memory fee8 = pairsStorage.fees(8);
        // console2.log("Fee name: %s", fee8.name);
        // console2.log("Open Fee: %d", fee8.openFeeP);
        // console2.log("Close Fee: %d", fee8.closeFeeP);
        // console2.log("Oracle Fee: %d", fee8.oracleFeeP);
        // console2.log("Trigger Order Fee: %d", fee8.triggerOrderFeeP);
        // console2.log("minPositionSizeUsd ", fee8.minPositionSizeUsd);

        // console2.log("==================================");
        // IPairsStorage.Fee memory fee9 = pairsStorage.fees(9);
        // console2.log("Fee name: %s", fee9.name);
        // console2.log("Open Fee: %d", fee9.openFeeP);
        // console2.log("Close Fee: %d", fee9.closeFeeP);
        // console2.log("Oracle Fee: %d", fee9.oracleFeeP);
        // console2.log("Trigger Order Fee: %d", fee9.triggerOrderFeeP);
        // console2.log("minPositionSizeUsd ", fee9.minPositionSizeUsd);

        // console2.log("==================================");
    }

    function testGroupsCount() public view {
        //     uint256 count = pairsStorage.groupsCount();
        //     console2.log("Groups count: %d", count);
    }

    function testGetGroup() public view {
        // IPairsStorage.Group memory group0 = pairsStorage.groups(0);
        // console2.log("Group name: %s", group0.name);
        // console2.logBytes32(group0.job);
        // console2.log("Min Leverage: %d", group0.minLeverage);
        // console2.log("Max Leverage: %d", group0.maxLeverage);

        // console2.log("==================================");
        // IPairsStorage.Group memory group1 = pairsStorage.groups(1);
        // console2.log("Group name: %s", group1.name);
        // console2.logBytes32(group1.job);
        // console2.log("Min Leverage: %d", group1.minLeverage);
        // console2.log("Max Leverage: %d", group1.maxLeverage);

        // console2.log("==================================");
        // IPairsStorage.Group memory group2 = pairsStorage.groups(2);
        // console2.log("Group name: %s", group2.name);
        // console2.logBytes32(group2.job);
        // console2.log("Min Leverage: %d", group2.minLeverage);
        // console2.log("Max Leverage: %d", group2.maxLeverage);

        // console2.log("==================================");
        // IPairsStorage.Group memory group3 = pairsStorage.groups(3);
        // console2.log("Group name: %s", group3.name);
        // console2.logBytes32(group3.job);
        // console2.log("Min Leverage: %d", group3.minLeverage);
        // console2.log("Max Leverage: %d", group3.maxLeverage);

        // console2.log("==================================");
        // IPairsStorage.Group memory group4 = pairsStorage.groups(4);
        // console2.log("Group name: %s", group4.name);
        // console2.logBytes32(group4.job);
        // console2.log("Min Leverage: %d", group4.minLeverage);
        // console2.log("Max Leverage: %d", group4.maxLeverage);

        // console2.log("==================================");
        // IPairsStorage.Group memory group5 = pairsStorage.groups(5);
        // console2.log("Group name: %s", group5.name);
        // console2.logBytes32(group5.job);
        // console2.log("Min Leverage: %d", group5.minLeverage);
        // console2.log("Max Leverage: %d", group5.maxLeverage);

        // console2.log("==================================");
        // IPairsStorage.Group memory group6 = pairsStorage.groups(6);
        // console2.log("Group name: %s", group6.name);
        // console2.logBytes32(group6.job);
        // console2.log("Min Leverage: %d", group6.minLeverage);
        // console2.log("Max Leverage: %d", group6.maxLeverage);

        // console2.log("==================================");
        // IPairsStorage.Group memory group7 = pairsStorage.groups(7);
        // console2.log("Group name: %s", group7.name);
        // console2.logBytes32(group7.job);
        // console2.log("Min Leverage: %d", group7.minLeverage);
        // console2.log("Max Leverage: %d", group7.maxLeverage);

        // console2.log("==================================");
        // IPairsStorage.Group memory group8 = pairsStorage.groups(8);
        // console2.log("Group name: %s", group8.name);
        // console2.logBytes32(group8.job);
        // console2.log("Min Leverage: %d", group8.minLeverage);
        // console2.log("Max Leverage: %d", group8.maxLeverage);

        // console2.log("==================================");
        // IPairsStorage.Group memory group9 = pairsStorage.groups(9);
        // console2.log("Group name: %s", group9.name);
        // console2.logBytes32(group9.job);
        // console2.log("Min Leverage: %d", group9.minLeverage);
        // console2.log("Max Leverage: %d", group9.maxLeverage);
    }

    function testPairsCount() public view {
        uint256 count = pairsStorage.pairsCount();
        console2.log("Pairs count: %d", count);
    }

    function testGetPair() public view {
        // IPairsStorage.Pair memory pair0 = pairsStorage.pairs(0);

        // console2.log("Pair from: %s", pair0.from);
        // console2.log("Pair to: %s", pair0.to);
        // console2.log("Spread: %d", pair0.spreadP);
        // console2.log("groupIndex: %d", pair0.groupIndex);
        // console2.log("feeIndex: %d", pair0.feeIndex);
        // console2.log("feed1 address: %s", pair0.feed.feed1);
        // console2.log("feed2 address: %s", pair0.feed.feed2);
        // console2.log("feedCalculation: %d", uint(pair0.feed.feedCalculation));
        // console2.log("maxDeviationP: %d", pair0.feed.maxDeviationP);

        console2.log("==================================");

        IPairsStorage.Pair memory pair1 = pairsStorage.pairs(1);

        console2.log("Pair from: %s", pair1.from);
        console2.log("Pair to: %s", pair1.to);
        console2.log("spreadP: %d", pair1.spreadP);
        console2.log("groupIndex: %d", pair1.groupIndex);
        console2.log("feeIndex: %d", pair1.feeIndex);
        console2.log("feed1 address: %s", pair1.feed.feed1);
        console2.log("feed2 address: %s", pair1.feed.feed2);
        console2.log("feedCalculation: %d", uint256(pair1.feed.feedCalculation));
        console2.log("maxDeviationP: %d", pair1.feed.maxDeviationP);

        // console2.log("==================================");
        // IPairsStorage.Pair memory pair10 = pairsStorage.pairs(10);
        // console2.log("Pair from: %s", pair10.from);
        // console2.log("Pair to: %s", pair10.to);
        // console2.log("Spread: %d", pair10.spreadP);
        // console2.log("groupIndex: %d", pair10.groupIndex);
        // console2.log("feeIndex: %d", pair10.feeIndex);
        // console2.log("feed1 address: %s", pair10.feed.feed1);
        // console2.log("feed2 address: %s", pair10.feed.feed2);
        // console2.log("feedCalculation: %d", uint256(pair10.feed.feedCalculation));
        // console2.log("maxDeviationP: %d", pair10.feed.maxDeviationP);
    }
}
