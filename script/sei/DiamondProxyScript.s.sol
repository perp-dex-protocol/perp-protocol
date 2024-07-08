// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";

contract DimondProxyScript is BaseScriptDeployer {
    function run() public {
        GNSMultiCollatDiamond diamond = new GNSMultiCollatDiamond();

        console2.log("Diamond deployed at: {}", address(diamond));
    }
}
