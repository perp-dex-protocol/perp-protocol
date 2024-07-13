// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSTradingCallbacks} from "src/core/facets/GNSTradingCallbacks.sol";
import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";
import {IDiamondStorage} from "src/interfaces/types/IDiamondStorage.sol";

contract TradingCallbackScript is BaseScriptDeployer {
    function run() public {
        GNSTradingCallbacks tradingCallbacks = new GNSTradingCallbacks();
        console2.log("tradingCallbacks ", address(tradingCallbacks));

        GNSMultiCollatDiamond diamond = GNSMultiCollatDiamond(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

        IDiamondStorage.FacetCut[] memory _faceCut = new IDiamondStorage.FacetCut[](1);
        _faceCut[0].facetAddress = address(tradingCallbacks);
        _faceCut[0].action = IDiamondStorage.FacetCutAction.ADD;

        bytes4[] memory selectors = new bytes4[](12);
        selectors[0] = bytes4(0x36c3dba2);
        selectors[1] = bytes4(0x4b0b5629);
        selectors[2] = bytes4(0xc61a7ad4);
        selectors[3] = bytes4(0x3b0c5938);
        selectors[4] = bytes4(0x2c6fe6d1);
        selectors[5] = bytes4(0xa5b26e46);
        selectors[6] = bytes4(0xec98ec83);
        selectors[7] = bytes4(0x13ebc2c6);
        selectors[8] = bytes4(0xcbc8e6f2);
        selectors[9] = bytes4(0xe1d88718);
        selectors[10] = bytes4(0x10d8e754);
        selectors[11] = bytes4(0x92dd2940);

        // 0x36c3dba2,0x4b0b5629,0xc61a7ad4,0x3b0c5938,0x2c6fe6d1,0xa5b26e46,0xec98ec83,0x13ebc2c6,0xcbc8e6f2,0xe1d88718,0x10d8e754,
        // 0x92dd2940

        _faceCut[0].functionSelectors = selectors;

        address _init = address(0);
        bytes memory _calldata = new bytes(0);

        diamond.diamondCut(_faceCut, _init, _calldata);

        address[] memory facets = diamond.facetAddresses();
        console2.log(facets.length);
        console2.log("facets0 ", facets[0]);
        console2.log("facets1 ", facets[1]);
        console2.log("facets2 ", facets[2]);
        console2.log("facets3 ", facets[3]);
        console2.log("facets4 ", facets[4]);
        console2.log("facets5 ", facets[5]);
        console2.log("facets6 ", facets[6]);
        console2.log("facets7 ", facets[7]);
    }
}
