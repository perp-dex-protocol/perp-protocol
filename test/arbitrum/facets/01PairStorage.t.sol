// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {BasicScriptTest} from "../BasicScriptTest.t.sol";
import {GNSPairsStorage} from "src/core/facets/GNSPairsStorage.sol";
import {IPairsStorage} from "src/interfaces/types/IPairsStorage.sol";

contract PairStorageTest is BasicScriptTest {
    address diamondcontract = 0xFF162c694eAA571f685030649814282eA457f169;
    GNSPairsStorage pairsStorage = GNSPairsStorage(diamondcontract);

    function testGetFees0() public view{
        IPairsStorage.Fee memory fee = pairsStorage.fees(0);
        console2.log("Fee name: %s", fee.name);
        console2.log("Open Fee: %d", fee.openFeeP);
        console2.log("Close Fee: %d", fee.closeFeeP);
        console2.log("Oracle Fee: %d", fee.oracleFeeP);
        console2.log("Trigger Order Fee: %d", fee.triggerOrderFeeP);
        console2.log("minPositionSizeUsd ", fee.minPositionSizeUsd);
    }

    function testGetFees1() public view {
        IPairsStorage.Fee memory fee = pairsStorage.fees(1);
        console2.log("Fee name: %s", fee.name);
        console2.log("Open Fee: %d", fee.openFeeP);
        console2.log("Close Fee: %d", fee.closeFeeP);
        console2.log("Oracle Fee: %d", fee.oracleFeeP);
        console2.log("Trigger Order Fee: %d", fee.triggerOrderFeeP);
        console2.log("minPositionSizeUsd ", fee.minPositionSizeUsd);
    }

    function testGetFees2() public view {
        IPairsStorage.Fee memory fee = pairsStorage.fees(2);
        console2.log("Fee name: %s", fee.name);
        console2.log("Open Fee: %d", fee.openFeeP);
        console2.log("Close Fee: %d", fee.closeFeeP);
        console2.log("Oracle Fee: %d", fee.oracleFeeP);
        console2.log("Trigger Order Fee: %d", fee.triggerOrderFeeP);
        console2.log("minPositionSizeUsd ", fee.minPositionSizeUsd);
    }

    function testGetFees3() public view {
        IPairsStorage.Fee memory fee = pairsStorage.fees(3);
        console2.log("Fee name: %s", fee.name);
        console2.log("Open Fee: %d", fee.openFeeP);
        console2.log("Close Fee: %d", fee.closeFeeP);
        console2.log("Oracle Fee: %d", fee.oracleFeeP);
        console2.log("Trigger Order Fee: %d", fee.triggerOrderFeeP);
        console2.log("minPositionSizeUsd ", fee.minPositionSizeUsd);
    }

    function testGetFees4() public view {
        IPairsStorage.Fee memory fee = pairsStorage.fees(4);
        console2.log("Fee name: %s", fee.name);
        console2.log("Open Fee: %d", fee.openFeeP);
        console2.log("Close Fee: %d", fee.closeFeeP);
        console2.log("Oracle Fee: %d", fee.oracleFeeP);
        console2.log("Trigger Order Fee: %d", fee.triggerOrderFeeP);
        console2.log("minPositionSizeUsd ", fee.minPositionSizeUsd);
    }

    function testGetFees5() public view {
        IPairsStorage.Fee memory fee = pairsStorage.fees(5);
        console2.log("Fee name: %s", fee.name);
        console2.log("Open Fee: %d", fee.openFeeP);
        console2.log("Close Fee: %d", fee.closeFeeP);
        console2.log("Oracle Fee: %d", fee.oracleFeeP);
        console2.log("Trigger Order Fee: %d", fee.triggerOrderFeeP);
        console2.log("minPositionSizeUsd ", fee.minPositionSizeUsd);
    }



}
