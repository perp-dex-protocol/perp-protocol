// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSTradingInteractions} from "src/core/facets/GNSTradingInteractions.sol";
import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";
import {IDiamondStorage} from "src/interfaces/types/IDiamondStorage.sol";

contract TriggerInteractionsScript is BaseScriptDeployer {
    GNSMultiCollatDiamond diamond = GNSMultiCollatDiamond(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

    function run() public {
        removeOldFacet();

        GNSTradingInteractions tradingInteractions = new GNSTradingInteractions();
        console2.log("tradingInteractions ", address(tradingInteractions));

        addNewFacet(address(tradingInteractions));

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
        console2.log("facets9 ", facets[9]);
    }

    function removeOldFacet() public {
        IDiamondStorage.FacetCut[] memory _faceCut = new IDiamondStorage.FacetCut[](1);
        _faceCut[0].facetAddress = address(0);
        _faceCut[0].action = IDiamondStorage.FacetCutAction.REMOVE;

        bytes4[] memory selectors = new bytes4[](29);

        selectors[0] = bytes4(0x85886333);
        selectors[1] = bytes4(0xbdb340cd);
        selectors[2] = bytes4(0x737b84cd);
        selectors[3] = bytes4(0x85898e08);
        selectors[4] = bytes4(0xa4bdee80);
        selectors[5] = bytes4(0x4aac6480);
        selectors[6] = bytes4(0x1d9478b6);
        selectors[7] = bytes4(0x5179cecf);
        selectors[8] = bytes4(0x84e93347);
        selectors[9] = bytes4(0x4465c3e4);
        selectors[10] = bytes4(0x080e83e1);
        selectors[11] = bytes4(0x031c722b);
        selectors[12] = bytes4(0x604755cf);
        selectors[13] = bytes4(0xeb9359aa);
        selectors[14] = bytes4(0x9bf1584e);
        selectors[15] = bytes4(0x52d029d2);
        selectors[16] = bytes4(0xa4bb127e);
        selectors[17] = bytes4(0xb5d9e9d0);
        selectors[18] = bytes4(0xf401f2bb);
        selectors[19] = bytes4(0xb6919540);
        selectors[20] = bytes4(0x69f6bde1);
        selectors[21] = bytes4(0x24058ad3);
        selectors[22] = bytes4(0x0bce9aaa);
        selectors[23] = bytes4(0x24d7d89a);
        selectors[24] = bytes4(0x567cf24e);
        selectors[25] = bytes4(0xfda4e0b5);
        selectors[26] = bytes4(0xd7362cc8);
        selectors[27] = bytes4(0x51ffadba);
        selectors[28] = bytes4(0x752e98fd);

        _faceCut[0].functionSelectors = selectors;

        address _init = address(0);
        bytes memory _calldata = new bytes(0);

        diamond.diamondCut(_faceCut, _init, _calldata);
    }

    function addNewFacet(address newFacet) public {
        IDiamondStorage.FacetCut[] memory _faceCut = new IDiamondStorage.FacetCut[](1);
        _faceCut[0].facetAddress = address(newFacet);
        _faceCut[0].action = IDiamondStorage.FacetCutAction.ADD;

        bytes4[] memory selectors = new bytes4[](29);

        selectors[0] = bytes4(0x85886333);
        selectors[1] = bytes4(0xbdb340cd);
        selectors[2] = bytes4(0x737b84cd);
        selectors[3] = bytes4(0x85898e08);
        selectors[4] = bytes4(0xa4bdee80);
        selectors[5] = bytes4(0x4aac6480);
        selectors[6] = bytes4(0x1d9478b6);
        selectors[7] = bytes4(0x5179cecf);
        selectors[8] = bytes4(0x84e93347);
        selectors[9] = bytes4(0x4465c3e4);
        selectors[10] = bytes4(0x080e83e1);
        selectors[11] = bytes4(0x031c722b);
        selectors[12] = bytes4(0x604755cf);
        selectors[13] = bytes4(0xeb9359aa);
        selectors[14] = bytes4(0x9bf1584e);
        selectors[15] = bytes4(0x52d029d2);
        selectors[16] = bytes4(0xa4bb127e);
        selectors[17] = bytes4(0xb5d9e9d0);
        selectors[18] = bytes4(0xf401f2bb);
        selectors[19] = bytes4(0xb6919540);
        selectors[20] = bytes4(0x69f6bde1);
        selectors[21] = bytes4(0x24058ad3);
        selectors[22] = bytes4(0x0bce9aaa);
        selectors[23] = bytes4(0x24d7d89a);
        selectors[24] = bytes4(0x567cf24e);
        selectors[25] = bytes4(0xfda4e0b5);
        selectors[26] = bytes4(0xd7362cc8);
        selectors[27] = bytes4(0x51ffadba);
        selectors[28] = bytes4(0x752e98fd); // increasePositionSizePayable

        // 0x85886333,0xbdb340cd,0x737b84cd,0x85898e08,0xa4bdee80,0x4aac6480,0x1d9478b6,0x5179cecf,0x84e93347,0x4465c3e4,
        // 0x080e83e1,0x031c722b,0x604755cf,0xeb9359aa,0x9bf1584e,0x52d029d2,0xa4bb127e,0xb5d9e9d0,0xf401f2bb,0xb6919540,
        // 0x69f6bde1,0x24058ad3,0x0bce9aaa
        _faceCut[0].functionSelectors = selectors;

        address _init = address(0);
        bytes memory _calldata = new bytes(0);

        diamond.diamondCut(_faceCut, _init, _calldata);
    }
}
