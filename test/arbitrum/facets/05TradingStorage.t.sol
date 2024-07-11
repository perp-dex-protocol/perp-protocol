// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {BasicScriptTest} from "../BasicScriptTest.t.sol";
import {GNSTradingStorage} from "src/core/facets/GNSTradingStorage.sol";
import {ITradingStorage} from "src/interfaces/types/ITradingStorage.sol";

contract TradingStorageTest is BasicScriptTest {
    address diamondcontract = 0xFF162c694eAA571f685030649814282eA457f169;

    GNSTradingStorage tradingStorage = GNSTradingStorage(diamondcontract);

    // function testGetCollateralCount() public view{
    //     uint8 count = tradingStorage.getCollateralsCount();
    //     console2.log("Collateral count: ", count);
    // }

    // function testGetCollaterals() public view {
    //     ITradingStorage.Collateral[] memory collaterals = tradingStorage.getCollaterals();

    //     for (uint8 i = 0; i < collaterals.length; i++) {
    //         console2.log("Collateral: ", collaterals[i].collateral);
    //         console2.log("isActive: ", collaterals[i].isActive);
    //         console2.log("placeholder: ", collaterals[i].__placeholder);
    //         console2.log("precision", collaterals[i].precision);
    //         console2.log("precisionDelta", collaterals[i].precisionDelta);
    //         console2.log("=====================================");
    //     }
    // }

    // function testGetTraders() public view {
    //     address[] memory traders = tradingStorage.getTraders(0, 10);
    //     console2.log(traders.length);

    //     console2.log("Traders:0 ", traders[0]);
    //     console2.log("Traders:1 ", traders[1]);
    //     console2.log("Traders:2 ", traders[2]);
    //     console2.log("Traders:3 ", traders[3]);
    //     console2.log("Traders:4 ", traders[4]);
    //     console2.log("Traders:5 ", traders[5]);
    //     console2.log("Traders:6 ", traders[6]);
    //     console2.log("Traders:7 ", traders[7]);
    //     console2.log("Traders:8 ", traders[8]);
    //     console2.log("Traders:9 ", traders[9]);

    // }

    //get all pending orders
    // function testGetAllPendingOrders() public view {
    //     ITradingStorage.PendingOrder[] memory pendingOrders = tradingStorage.getAllPendingOrders(0, 10);
    //     console2.log(pendingOrders.length);

    //     console2.log("PendingOrders:0 user ", pendingOrders[0].user);
    //     console2.log("PendingOrders:0 index ", pendingOrders[0].index);
    //     console2.log("PendingOrders:0 isOpen ", pendingOrders[0].isOpen);
    //     console2.log("PendingOrders:0 createdBlock ", pendingOrders[0].createdBlock);
    //     console2.log("PendingOrders:0 maxSlippageP ", pendingOrders[0].maxSlippageP);
    // }

    // get gToken
    function testGetGToken() public view {
        address gtoken = tradingStorage.getGToken(3);
        console2.log("GToken: ", gtoken);
    }
}
