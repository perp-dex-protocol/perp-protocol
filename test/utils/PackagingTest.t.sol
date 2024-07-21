// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";

contract PackagingTest is Test {
    function testPackaging() public {
        uint256 packedData = 127941788066531900842471442757030902657128318382907654;
        (uint8 orderType, address trader, uint32 index) = unpackTriggerOrder(packedData);
        console2.log("orderType ", orderType);
        console2.log("trader ", trader);
        console2.log("index ", index);

        uint256 packed = packTriggerOrder(orderType, trader, index);
        console2.log("packed ", packed);

        assertEq(packed, packedData);
    }

    function unpackTriggerOrder(uint256 _packed)
        internal
        pure
        returns (uint8 orderType, address trader, uint32 index)
    {
        orderType = uint8(_packed & 0xFF); // 8 bits
        trader = address(uint160(_packed >> 8)); // 160 bits
        index = uint32((_packed >> 168)); // 32 bits
    }

    function packTriggerOrder(uint8 orderType, address trader, uint32 index) internal pure returns (uint256 packed) {
        packed = uint256(orderType) | (uint256(uint160(trader)) << 8) | (uint256(index) << 168);
    }
}
