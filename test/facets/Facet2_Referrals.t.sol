// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";

contract AddressTest is Test {
    address Alice = makeAddr("Alice");

    function testGetAddress() public {
        console2.log(Alice);
        vm.startPrank(Alice);
    }
}

contract Attacker {
    function getAddress() public view returns (address) {
        return address(this);
    }

    function execute() public {}
}
