// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSPriceAggregator} from "src/core/facets/GNSPriceAggregator.sol";
import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";
import {IDiamondStorage} from "src/interfaces/types/IDiamondStorage.sol";

contract PriceAggregatorScript is BaseScriptDeployer {
    function run() public {
        // GNSPriceAggregator priceAggregator = new GNSPriceAggregator();
        // console2.log("priceAggregator ", address(priceAggregator));

        GNSMultiCollatDiamond diamond = GNSMultiCollatDiamond(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

        IDiamondStorage.FacetCut[] memory _faceCut = new IDiamondStorage.FacetCut[](1);
        _faceCut[0].facetAddress = address(1);
        _faceCut[0].action = IDiamondStorage.FacetCutAction.REMOVE;

        bytes4[] memory selectors = new bytes4[](36);
        selectors[0] = bytes4(0xdf5dd1a5);
        selectors[1] = bytes4(0x6f37d263);
        selectors[2] = bytes4(0x4357855e);
        selectors[3] = bytes4(0x165d35e1);
        selectors[4] = bytes4(0x36f6def7);
        selectors[5] = bytes4(0xbbb4e3f9);
        selectors[6] = bytes4(0x9641c1f5);
        selectors[7] = bytes4(0x1de109d2);
        selectors[8] = bytes4(0xa91fa361);
        selectors[9] = bytes4(0x6e27030b);
        selectors[10] = bytes4(0x891e656c);
        selectors[11] = bytes4(0xf4b0664d);
        selectors[12] = bytes4(0x9cf0cc0e);
        selectors[13] = bytes4(0xb144bbf0);
        selectors[14] = bytes4(0x8e667ac8);
        selectors[15] = bytes4(0x69b53230);
        selectors[16] = bytes4(0x10a9de60);
        selectors[17] = bytes4(0x40884c52);
        selectors[18] = bytes4(0x88b12d55);
        selectors[19] = bytes4(0xf51d0dc0);
        selectors[20] = bytes4(0x7d0fcd1e);
        selectors[21] = bytes4(0x9f62038f);
        selectors[22] = bytes4(0x3fad1834);
        selectors[23] = bytes4(0x3e742e3b);
        selectors[24] = bytes4(0xbbad411a);
        selectors[25] = bytes4(0x80935dbf);
        selectors[26] = bytes4(0x25e589cd);
        selectors[27] = bytes4(0xe0bb91c2);
        selectors[28] = bytes4(0x85f276b8);
        selectors[29] = bytes4(0xc07d2844);
        selectors[30] = bytes4(0x5beda778);
        selectors[31] = bytes4(0x44eb8ba6);
        selectors[32] = bytes4(0xb166a495);
        selectors[33] = bytes4(0x6a43c9ad);
        selectors[34] = bytes4(0xf1dd8b66);
        selectors[35] = bytes4(0x2caa6f8a);

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
        console2.log("facets8 ", facets[8]);
        // console2.log("facets9 ", facets[9]);

        // 0xdf5dd1a5,0x6f37d263,0x4357855e,0x165d35e1,0x36f6def7,0xbbb4e3f9,0x9641c1f5,0x1de109d2,0xa91fa361,0x6e27030b,
        // 0x891e656c,0xf4b0664d,0x9cf0cc0e,0xb144bbf0,0x8e667ac8,0x69b53230,0x10a9de60,0x40884c52,0x88b12d55,0xf51d0dc0,
        // 0x7d0fcd1e,0x9f62038f,0x3fad1834,0x3e742e3b,0xbbad411a,0x80935dbf,0x25e589cd,0xe0bb91c2,0x85f276b8,0xc07d2844,
        // 0x5beda778,0x44eb8ba6,0xb166a495,0x6a43c9ad,0xf1dd8b66,0x2caa6f8a
    }
}
