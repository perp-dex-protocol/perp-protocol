// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSFeeTiers} from "src/core/facets/GNSFeeTiers.sol";
import {GNSPriceImpact} from "src/core/facets/GNSPriceImpact.sol";

import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";
import {IDiamondStorage} from "src/interfaces/types/IDiamondStorage.sol";

contract GNSFeeTierScript is BaseScriptDeployer {
    function run() public {
        // GNSFeeTiers feetier = new GNSFeeTiers();
        // console2.log("feetier  ", address(feetier));

        GNSMultiCollatDiamond diamond = GNSMultiCollatDiamond(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

        IDiamondStorage.FacetCut[] memory _faceCut = new IDiamondStorage.FacetCut[](1);
        _faceCut[0].facetAddress = address(0x98DBa8fAd06b6ba8c14Cd0eb63D5c3244E8fB6BA);
        _faceCut[0].action = IDiamondStorage.FacetCutAction.ADD;
        bytes4[] memory selectors = new bytes4[](10);
        selectors[0] = bytes4(0x4f09a236);
        selectors[1] = bytes4(0xeccea3e2);
        selectors[2] = bytes4(0xa89db8e5);
        selectors[3] = bytes4(0x794d8520);
        selectors[4] = bytes4(0xacbaaf33);
        selectors[5] = bytes4(0x31ca4887);
        selectors[6] = bytes4(0x33534de2);
        selectors[7] = bytes4(0xeced5249);
        selectors[8] = bytes4(0x944f577a);
        selectors[9] = bytes4(0xfed8a190);

        //0x4f09a236,0xeccea3e2,0xa89db8e5,0x794d8520,0xacbaaf33,0x31ca4887,0x33534de2,0xeced5249,0x944f577a,0xfed8a190]

        _faceCut[0].functionSelectors = selectors;
        address _init = address(0);
        bytes memory _calldata = new bytes(0);
        // diamond.diamondCut(_faceCut, _init, _calldata);

        address[] memory facets = diamond.facetAddresses();
        console2.log("facets0 ", facets[0]);
        console2.log("facets1 ", facets[1]);
        console2.log("facets2 ", facets[2]);
        console2.log("facets3 ", facets[3]);
    }
}
