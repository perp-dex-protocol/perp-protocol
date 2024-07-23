// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";

contract PriceImpactScript is BaseScriptDeployer{
    function run() public {
        console2.log(block.number);
    }
}