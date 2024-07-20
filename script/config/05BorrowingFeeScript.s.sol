// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSBorrowingFees} from "src/core/facets/GNSBorrowingFees.sol";
import "src/interfaces/types/IBorrowingFees.sol";

contract BorrowingFeeScript is BaseScriptDeployer {
    GNSBorrowingFees borrowingFees = GNSBorrowingFees(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

    // struct BorrowingPairParams {
    //     uint16 groupIndex;
    //     uint32 feePerBlock; // 1e10 (%)
    //     uint48 feeExponent;
    //     uint72 maxOi;
    // }

    function run() public {
        // addBorrowPair();
        addBorrowGroup();
        uint256 pairOi = borrowingFees.getPairOiCollateral(1, 0, true);
        console2.log(pairOi);
        uint256 collateral = borrowingFees.getPairMaxOiCollateral(1, 0);
        console2.log(collateral);
    }

    function addBorrowPair() public {
        // groupIndex 0 
        // feePerBlock 30000, according arbitrum 100000
        // feeExponent  1 
        // maxOi    34511200000000000
        IBorrowingFees.BorrowingPairParams memory pairParams = IBorrowingFees.BorrowingPairParams(0, 100000, 1, 0.07 ether);

        borrowingFees.setBorrowingPairParams(1, 0, pairParams);
    }

    function addBorrowGroup() public {

        // 1. feePerblock 60000
        // 2. 0.5 e18
        // 3. feeExponent 1

        IBorrowingFees.BorrowingGroupParams memory groupParams = IBorrowingFees.BorrowingGroupParams(60000, 0.5 ether, 1);

        borrowingFees.setBorrowingGroupParams(1, 1, groupParams);
    }
}
