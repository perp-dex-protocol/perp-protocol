// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSTriggerRewards} from "src/core/facets/GNSTriggerRewards.sol";
import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";
import {IDiamondStorage} from "src/interfaces/types/IDiamondStorage.sol";

contract TriggerRewardsScript is BaseScriptDeployer {
    function run() public {
        // GNSTriggerRewards rewards = new GNSTriggerRewards();
        // console2.log("rewards  ", address(rewards));

        GNSMultiCollatDiamond diamond = GNSMultiCollatDiamond(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

        IDiamondStorage.FacetCut[] memory _faceCut = new IDiamondStorage.FacetCut[](1);
        _faceCut[0].facetAddress = address(0);
        _faceCut[0].action = IDiamondStorage.FacetCutAction.REMOVE;

        bytes4[] memory selectors = new bytes4[](7);
        selectors[0] = bytes4(0x63790a1b);
        selectors[1] = bytes4(0x69f5395e);
        selectors[2] = bytes4(0x9fd0bdad);
        selectors[3] = bytes4(0x1187f9bd);
        selectors[4] = bytes4(0x8765f772);
        selectors[5] = bytes4(0xe2c3542b);
        selectors[6] = bytes4(0x9e353611);
        // 0x63790a1b,0x69f5395e,0x9fd0bdad,0x1187f9bd,0x8765f772,0xe2c3542b,0x9e353611

        _faceCut[0].functionSelectors = selectors;
        address _init = address(0);
        bytes memory _calldata = new bytes(0);
        diamond.diamondCut(_faceCut, _init, _calldata);

        // address[] memory facets = diamond.facetAddresses();
        // console2.log(facets.length);
        // console2.log("facets0 ", facets[0]);
        // console2.log("facets1 ", facets[1]);
        // console2.log("facets2 ", facets[2]);
        // console2.log("facets3 ", facets[3]);
        // console2.log("facets4 ", facets[4]);
        // console2.log("facets5 ", facets[5]);
    }
}
