// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";

import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";
import {IDiamondStorage} from "src/interfaces/types/IDiamondStorage.sol";

contract DiamondAddRemoveFacetsScript is BaseScriptDeployer {
    GNSMultiCollatDiamond diamond = GNSMultiCollatDiamond(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

    function run() public {
        address[] memory addrs = diamond.facetAddresses();
        console2.log("facets", addrs.length);

        // remove facets from diamond

        address priceImpactFacet = 0xBbceA45b8EFc6579772be09f69CA785b9640e2Fe;

        IDiamondStorage.FacetCut memory facetCut = IDiamondStorage.FacetCut({
            facetAddress: priceImpactFacet,
            action: IDiamondStorage.FacetCutAction.REMOVE,
            functionSelectors: new bytes4[](0)
        });
    }
}
