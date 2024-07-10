// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSTradingStorage} from "src/core/facets/GNSTradingStorage.sol";
import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";
import {IDiamondStorage} from "src/interfaces/types/IDiamondStorage.sol";

contract TradingStorageScript is BaseScriptDeployer {
    function run() public {
        // GNSTradingStorage tradingStorage = new GNSTradingStorage();
        // console2.log("tradingStorage  ", address(tradingStorage));

        GNSMultiCollatDiamond diamond = GNSMultiCollatDiamond(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

        IDiamondStorage.FacetCut[] memory _faceCut = new IDiamondStorage.FacetCut[](1);
        _faceCut[0].facetAddress = address(0xf929cb41812e2FB358B5026d91f076ed27296907);
        _faceCut[0].action = IDiamondStorage.FacetCutAction.ADD;
        bytes4[] memory selectors = new bytes4[](35);
        selectors[0] = bytes4(0xc6783af1);
        selectors[1] = bytes4(0x4fb70bba);
        selectors[2] = bytes4(0x8583909b);
        selectors[3] = bytes4(0x2d11445f);
        selectors[4] = bytes4(0xeb50287f);
        selectors[5] = bytes4(0xdffd8a1f);
        selectors[6] = bytes4(0xbb33a55b);
        selectors[7] = bytes4(0x5c3ed7c3);
        selectors[8] = bytes4(0x78b92636);
        selectors[9] = bytes4(0xa3e15d09);
        selectors[10] = bytes4(0x0212f0d6);
        selectors[11] = bytes4(0x6a0aff41);
        selectors[12] = bytes4(0xc6e729bb);
        selectors[13] = bytes4(0x4c73cb25);
        selectors[14] = bytes4(0x15878e07);
        selectors[15] = bytes4(0x75cd812d);
        selectors[16] = bytes4(0x0d1e3c94);
        selectors[17] = bytes4(0x067e84dd);
        selectors[18] = bytes4(0xbed8d2da);
        selectors[19] = bytes4(0x0e503724);
        selectors[20] = bytes4(0x4bfad7c0);
        selectors[21] = bytes4(0x4115c122);
        selectors[22] = bytes4(0x1b7d88e5);
        selectors[23] = bytes4(0x4d140218);
        selectors[24] = bytes4(0x1d2ffb42);
        selectors[25] = bytes4(0x93f9384e);
        selectors[26] = bytes4(0x9f30b640);
        selectors[27] = bytes4(0x49f7895b);
        selectors[28] = bytes4(0x63450d74);
        selectors[29] = bytes4(0xeb2dfde8);
        selectors[30] = bytes4(0x5a68200d);
        selectors[31] = bytes4(0x1053c279);
        selectors[32] = bytes4(0xb8f741d4);
        selectors[33] = bytes4(0xb78f4b36);
        selectors[34] = bytes4(0x7281d8f8);

        _faceCut[0].functionSelectors = selectors;
        address _init = address(0);
        bytes memory _calldata = new bytes(0);
        diamond.diamondCut(_faceCut, _init, _calldata);

        address[] memory facets = diamond.facetAddresses();

        console2.log("facets0 ", facets[0]);
        console2.log("facets1 ", facets[1]);
        console2.log("facets2 ", facets[2]);
        console2.log("facets3 ", facets[3]);
        console2.log("facets4 ", facets[4]);

        // 0xc6783af1,0x4fb70bba,0x8583909b,0x2d11445f,0xeb50287f,0xdffd8a1f,0xbb33a55b,0x5c3ed7c3,0x78b92636,0xa3e15d09,
        // 0x0212f0d6,0x6a0aff41,0xc6e729bb,0x4c73cb25,0x15878e07,0x75cd812d,0x0d1e3c94,0x067e84dd,0xbed8d2da,0x0e503724,
        // 0x4bfad7c0,0x4115c122,0x1b7d88e5,0x4d140218,0x1d2ffb42,0x93f9384e,0x9f30b640,0x49f7895b,0x63450d74,0xeb2dfde8,
        // 0x5a68200d,0x1053c279,0xb8f741d4,0xb78f4b36,0x7281d8f8
    }
}
