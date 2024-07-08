// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";
import {IAddressStore} from "src/interfaces/types/IAddressStore.sol";

contract DiamondProxyTest is Test {
    GNSMultiCollatDiamond diamond;

    function setUp() public {
        vm.createSelectFork("https://evm-rpc.sei-apis.com");
        diamond = new GNSMultiCollatDiamond();
    }

    function testDeployDiamondProxy() public {
        IAddressStore.Addresses memory addresses = diamond.getAddresses();
        console2.log("addresses.gns", addresses.gns);
        console2.log("addresses.gnsStaking", addresses.gnsStaking);
    }
}
