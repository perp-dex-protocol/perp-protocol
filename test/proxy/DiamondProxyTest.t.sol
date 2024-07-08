// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";

contract DiamondProxyTest is Test {
    function setUp() public {}

    function testDeployDiamondProxy() public {
        GNSMultiCollatDiamond diamond = new GNSMultiCollatDiamond();
        console2.log("diamond address  ", address(diamond));
    }
}
