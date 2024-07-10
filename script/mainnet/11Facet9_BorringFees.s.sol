// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSBorrowingFees} from "src/core/facets/GNSBorrowingFees.sol";

contract BorringFeesScript is BaseScriptDeployer {
    function run() public {
        GNSBorrowingFees borringFees = new GNSBorrowingFees();
        console2.log("borringFees ", address(borringFees));
    }
}
