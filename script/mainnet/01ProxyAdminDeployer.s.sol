// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract proxyAdminDeployer is BaseScriptDeployer {
    function run() public {
        ProxyAdmin proxyAdmin = new ProxyAdmin();

        console2.log("ProxyAdmin deployed at:", address(proxyAdmin));
    }
}
