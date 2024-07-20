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
        addBorrowPair();

        uint256 pairOi = borrowingFees.getPairOiCollateral(1, 0, true);
        console2.log(pairOi);
        uint256 collateral = borrowingFees.getPairMaxOiCollateral(1, 0);
        console2.log(collateral);
    }

    function addBorrowPair() public {
        IBorrowingFees.BorrowingPairParams memory pairParams = IBorrowingFees.BorrowingPairParams(0, 1, 1, 1000000);

        borrowingFees.setBorrowingPairParams(1, 0, pairParams);
    }

    function addBorrowGroup() public {
        IBorrowingFees.BorrowingGroupParams memory groupParams = IBorrowingFees.BorrowingGroupParams(0, 1, 1000000);

        borrowingFees.setBorrowingGroupParams(1, 0, groupParams);
    }
}
