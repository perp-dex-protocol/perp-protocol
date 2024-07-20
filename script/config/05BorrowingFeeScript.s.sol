// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSBorrowingFees} from "src/core/facets/GNSBorrowingFees.sol";

contract BorrowingFeeScript is BaseScriptDeployer {
    GNSBorrowingFees borrowingFees = GNSBorrowingFees(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

    function run() public {
        uint256 collateral = borrowingFees.getPairMaxOiCollateral(1, 0);
        console2.logUint(collateral);
    }
}
