// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSPriceImpact} from "src/core/facets/GNSPriceImpact.sol";
import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";
import {IDiamondStorage} from "src/interfaces/types/IDiamondStorage.sol";

contract PriceImpactScript is BaseScriptDeployer {
    GNSMultiCollatDiamond diamond = GNSMultiCollatDiamond(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

    function run() public {
        removeOldFacet();
        GNSPriceImpact priceImpact = new GNSPriceImpact();
        console2.log("priceImpact  ", address(priceImpact));
        addNewFacet(address(priceImpact));

        priceImpact = GNSPriceImpact(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

        priceImpact.initializePriceImpact(7200, 3);

        address[] memory facets = diamond.facetAddresses();
        console2.log("facets0 ", facets[0]);
        console2.log("facets1 ", facets[1]);
        console2.log("facets2 ", facets[2]);
        console2.log("facets3 ", facets[3]);
    }

    function removeOldFacet() public {
        IDiamondStorage.FacetCut[] memory _faceCut = new IDiamondStorage.FacetCut[](1);
        _faceCut[0].facetAddress = address(0);
        _faceCut[0].action = IDiamondStorage.FacetCutAction.REMOVE;
        bytes4[] memory selectors = new bytes4[](15);

        selectors[0] = bytes4(0x823ef2ac);
        selectors[1] = bytes4(0x0d12f7cb);
        selectors[2] = bytes4(0xb56df676);
        selectors[3] = bytes4(0x375bb2bb);
        selectors[4] = bytes4(0x0d569f27);
        selectors[5] = bytes4(0xb6d92b02);
        selectors[6] = bytes4(0x7ea95f32);
        selectors[7] = bytes4(0x01d5664a);
        selectors[8] = bytes4(0x6474b399);
        selectors[9] = bytes4(0x10751b4f);
        selectors[10] = bytes4(0x39b0fc82);
        selectors[11] = bytes4(0x4c8a7602);
        selectors[12] = bytes4(0x273064f2);
        selectors[13] = bytes4(0xc3248367);
        selectors[14] = bytes4(0x2f29a9e8);
        // 0x823ef2ac ,0x0d12f7cb,0xb56df676,0x375bb2bb,0x0d569f27,0xb6d92b02,0x7ea95f32,0x01d5664a,0x6474b399,0x10751b4f,0x39b0fc82,0x4c8a7602,0x273064f2,0xc3248367,0x2f29a9e8

        _faceCut[0].functionSelectors = selectors;
        address _init = address(0);
        bytes memory _calldata = new bytes(0);
        diamond.diamondCut(_faceCut, _init, _calldata);
    }

    function addNewFacet(address newFacet) public {
        IDiamondStorage.FacetCut[] memory _faceCut = new IDiamondStorage.FacetCut[](1);
        _faceCut[0].facetAddress = address(newFacet);
        _faceCut[0].action = IDiamondStorage.FacetCutAction.ADD;
        bytes4[] memory selectors = new bytes4[](15);

        selectors[0] = bytes4(0x823ef2ac);
        selectors[1] = bytes4(0x0d12f7cb);
        selectors[2] = bytes4(0xb56df676);
        selectors[3] = bytes4(0x375bb2bb);
        selectors[4] = bytes4(0x0d569f27);
        selectors[5] = bytes4(0xb6d92b02);
        selectors[6] = bytes4(0x7ea95f32);
        selectors[7] = bytes4(0x01d5664a);
        selectors[8] = bytes4(0x6474b399);
        selectors[9] = bytes4(0x10751b4f);
        selectors[10] = bytes4(0x39b0fc82);
        selectors[11] = bytes4(0x4c8a7602);
        selectors[12] = bytes4(0x273064f2);
        selectors[13] = bytes4(0xc3248367);
        selectors[14] = bytes4(0x2f29a9e8);
        // 0x823ef2ac ,0x0d12f7cb,0xb56df676,0x375bb2bb,0x0d569f27,0xb6d92b02,0x7ea95f32,0x01d5664a,0x6474b399,0x10751b4f,0x39b0fc82,0x4c8a7602,0x273064f2,0xc3248367,0x2f29a9e8

        _faceCut[0].functionSelectors = selectors;
        address _init = address(0);
        bytes memory _calldata = new bytes(0);
        diamond.diamondCut(_faceCut, _init, _calldata);
    }
}
