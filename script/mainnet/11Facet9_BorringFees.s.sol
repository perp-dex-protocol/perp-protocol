// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSBorrowingFees} from "src/core/facets/GNSBorrowingFees.sol";
import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";
import {IDiamondStorage} from "src/interfaces/types/IDiamondStorage.sol";

contract BorringFeesScript is BaseScriptDeployer {
    GNSMultiCollatDiamond diamond = GNSMultiCollatDiamond(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

    function run() public {
        removeOldFacet();

        GNSBorrowingFees borringFees = new GNSBorrowingFees();
        console2.log("borringFees ", address(borringFees));

        addNewFacet(address(borringFees));

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

        // 0x48da5b38,0xfff24740,0x13a9baae,0xd2b9099a,0xfbbf9740,0xab6192ed,0x5d5bf24d,0xe6a6633f,0xfd03e048,0x0077b57e,
        // 0x0c7be6ca,0x5667b5c0,0x274d1278,0xeb2ea3a2,0xf6f7c948,0x0804db93,0xfc79e929,0x9fed9481,0x02c4e7c1,0x33b516cf,
        // 0xeb1802f8,0x801c7961,0xea122fd8,0x4fa72788
    }

    function removeOldFacet() public {
        IDiamondStorage.FacetCut[] memory _faceCut = new IDiamondStorage.FacetCut[](1);
        _faceCut[0].facetAddress = address(0);
        _faceCut[0].action = IDiamondStorage.FacetCutAction.REMOVE;

        bytes4[] memory selectors = new bytes4[](24);
        selectors[0] = bytes4(0x48da5b38);
        selectors[1] = bytes4(0xfff24740);
        selectors[2] = bytes4(0x13a9baae);
        selectors[3] = bytes4(0xd2b9099a);
        selectors[4] = bytes4(0xfbbf9740);
        selectors[5] = bytes4(0xab6192ed);
        selectors[6] = bytes4(0x5d5bf24d);
        selectors[7] = bytes4(0xe6a6633f);
        selectors[8] = bytes4(0xfd03e048);
        selectors[9] = bytes4(0x0077b57e);
        selectors[10] = bytes4(0x0c7be6ca);
        selectors[11] = bytes4(0x5667b5c0);
        selectors[12] = bytes4(0x274d1278);
        selectors[13] = bytes4(0xeb2ea3a2);
        selectors[14] = bytes4(0xf6f7c948);
        selectors[15] = bytes4(0x0804db93);
        selectors[16] = bytes4(0xfc79e929);
        selectors[17] = bytes4(0x9fed9481);
        selectors[18] = bytes4(0x02c4e7c1);
        selectors[19] = bytes4(0x33b516cf);
        selectors[20] = bytes4(0xeb1802f8);
        selectors[21] = bytes4(0x801c7961);
        selectors[22] = bytes4(0xea122fd8);
        selectors[23] = bytes4(0x4fa72788);

        _faceCut[0].functionSelectors = selectors;

        address _init = address(0);
        bytes memory _calldata = new bytes(0);

        diamond.diamondCut(_faceCut, _init, _calldata);
    }

    function addNewFacet(address newFacet) public {
        IDiamondStorage.FacetCut[] memory _faceCut = new IDiamondStorage.FacetCut[](1);
        _faceCut[0].facetAddress = address(newFacet);
        _faceCut[0].action = IDiamondStorage.FacetCutAction.ADD;

        bytes4[] memory selectors = new bytes4[](24);
        selectors[0] = bytes4(0x48da5b38);
        selectors[1] = bytes4(0xfff24740);
        selectors[2] = bytes4(0x13a9baae);
        selectors[3] = bytes4(0xd2b9099a);
        selectors[4] = bytes4(0xfbbf9740);
        selectors[5] = bytes4(0xab6192ed);
        selectors[6] = bytes4(0x5d5bf24d);
        selectors[7] = bytes4(0xe6a6633f);
        selectors[8] = bytes4(0xfd03e048);
        selectors[9] = bytes4(0x0077b57e);
        selectors[10] = bytes4(0x0c7be6ca);
        selectors[11] = bytes4(0x5667b5c0);
        selectors[12] = bytes4(0x274d1278);
        selectors[13] = bytes4(0xeb2ea3a2);
        selectors[14] = bytes4(0xf6f7c948);
        selectors[15] = bytes4(0x0804db93);
        selectors[16] = bytes4(0xfc79e929);
        selectors[17] = bytes4(0x9fed9481);
        selectors[18] = bytes4(0x02c4e7c1);
        selectors[19] = bytes4(0x33b516cf);
        selectors[20] = bytes4(0xeb1802f8);
        selectors[21] = bytes4(0x801c7961);
        selectors[22] = bytes4(0xea122fd8);
        selectors[23] = bytes4(0x4fa72788);

        _faceCut[0].functionSelectors = selectors;

        address _init = address(0);
        bytes memory _calldata = new bytes(0);

        diamond.diamondCut(_faceCut, _init, _calldata);
    }
}
