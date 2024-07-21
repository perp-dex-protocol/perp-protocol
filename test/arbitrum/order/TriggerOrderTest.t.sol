// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {GNSTradingInteractions} from "src/core/facets/GNSTradingInteractions.sol";

contract OrderTriggerTest is Test {

    GNSTradingInteractions tradingContract = GNSTradingInteractions(payable(0x209A9A01980377916851af2cA075C2b170452018));

    function setUp() public {
        vm.createSelectFork("https://rpc.ankr.com/polygon", 59620732);
    }

    function testTriggerOrderDetail() public {

        vm.startPrank(0xc83B78A64485e24BE0AF82aE2341c42DC5Bd8fd8);

         uint256 packedData = 59066947098549230987099741152215251779760259166679810;
        (uint8 orderType, address trader, uint32 index) = unpackTriggerOrder(packedData);
        console2.log("orderType ", orderType);
        console2.log("trader ", trader);
        console2.log("index ", index);

        uint256 packed = packTriggerOrder(orderType, trader, index);

        tradingContract.triggerOrder(packed);
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
