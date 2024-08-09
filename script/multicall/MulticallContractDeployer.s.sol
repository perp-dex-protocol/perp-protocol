// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {MultiCall} from "./MultiCall.sol";

contract MulticallContractDeployer is BaseScriptDeployer {
    function run() public {
        MultiCall multicall = new MultiCall();
        console2.log("Multicall contract deployed at address: ", address(multicall));
    }
}
