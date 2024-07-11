// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {BasicScriptTest} from "../BasicScriptTest.t.sol";
import {GNSFeeTiers} from "src/core/facets/GNSFeeTiers.sol";
import {IFeeTiers} from "src/interfaces/types/IFeeTiers.sol";

contract FeeTiersTest is BasicScriptTest {
    address diamondcontract = 0xFF162c694eAA571f685030649814282eA457f169;
    GNSFeeTiers feeTiers = GNSFeeTiers(diamondcontract);

    // function testGetFeeTierCount() public {
    //     uint256 feeTierCount = feeTiers.getFeeTiersCount();
    //     console2.logUint(feeTierCount);
    // }

    // 8
    function testGetFeeTierData() public view {
        IFeeTiers.FeeTier memory feetier0 = feeTiers.getFeeTier(0);
        console2.logUint(feetier0.feeMultiplier);
        console2.logUint(feetier0.pointsThreshold);

        console2.log("=====================================");
        IFeeTiers.FeeTier memory feetier1 = feeTiers.getFeeTier(1);
        console2.logUint(feetier1.feeMultiplier);
        console2.logUint(feetier1.pointsThreshold);

        console2.log("=====================================");
        IFeeTiers.FeeTier memory feetier2 = feeTiers.getFeeTier(2);
        console2.logUint(feetier2.feeMultiplier);
        console2.logUint(feetier2.pointsThreshold);

        console2.log("=====================================");
        IFeeTiers.FeeTier memory feetier3 = feeTiers.getFeeTier(3);
        console2.logUint(feetier3.feeMultiplier);
        console2.logUint(feetier3.pointsThreshold);

        console2.log("=====================================");
        IFeeTiers.FeeTier memory feetier4 = feeTiers.getFeeTier(4);
        console2.logUint(feetier4.feeMultiplier);
        console2.logUint(feetier4.pointsThreshold);

        console2.log("=====================================");
        IFeeTiers.FeeTier memory feetier5 = feeTiers.getFeeTier(5);
        console2.logUint(feetier5.feeMultiplier);
        console2.logUint(feetier5.pointsThreshold);

        console2.log("=====================================");
        IFeeTiers.FeeTier memory feetier6 = feeTiers.getFeeTier(6);
        console2.logUint(feetier6.feeMultiplier);
        console2.logUint(feetier6.pointsThreshold);

        console2.log("=====================================");
        IFeeTiers.FeeTier memory feetier7 = feeTiers.getFeeTier(7);
        console2.logUint(feetier7.feeMultiplier);
        console2.logUint(feetier7.pointsThreshold);

        console2.log("=====================================");
    }
}
