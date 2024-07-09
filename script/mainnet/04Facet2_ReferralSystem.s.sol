// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSReferrals} from "src/core/facets/GNSReferrals.sol";
import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";
import {IDiamondStorage} from "src/interfaces/types/IDiamondStorage.sol";

contract GNSReferralsScript is BaseScriptDeployer {
    function run() public {
        // GNSReferrals referrals = new GNSReferrals();
        // console2.log("referrals", address(referrals));

        // 2. add diamond cut
        GNSMultiCollatDiamond diamond = GNSMultiCollatDiamond(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

        IDiamondStorage.FacetCut[] memory _faceCut = new IDiamondStorage.FacetCut[](1);
        _faceCut[0].facetAddress = address(0xECa90C0866032FFfAE15b10631c7Cad887Cd2E97);
        _faceCut[0].action = IDiamondStorage.FacetCutAction.ADD;
        bytes4[] memory selectors = new bytes4[](24);
        selectors[0] = bytes4(0xee6cf884);
        selectors[1] = bytes4(0x65cbd307);
        selectors[2] = bytes4(0xfa3c8dbf);
        selectors[3] = bytes4(0x92e67406);
        selectors[4] = bytes4(0x97436b5f);
        selectors[5] = bytes4(0x06350917);
        selectors[6] = bytes4(0x843b9e5d);
        selectors[7] = bytes4(0x71159fd1);
        selectors[8] = bytes4(0xcbe0f32e);
        selectors[9] = bytes4(0x4e583b31);
        selectors[10] = bytes4(0xa73a3e35);
        selectors[11] = bytes4(0x036787e5);
        selectors[12] = bytes4(0x46dbf572);
        selectors[13] = bytes4(0x32a7b732);
        selectors[14] = bytes4(0xc8b0d710);
        selectors[15] = bytes4(0x9b8ab684);
        selectors[16] = bytes4(0x3450191e);
        selectors[17] = bytes4(0x92b2bbae);
        selectors[18] = bytes4(0x97365b74);
        selectors[19] = bytes4(0xdfed4fcb);
        selectors[20] = bytes4(0x66ddd309);
        selectors[21] = bytes4(0x03e37464);
        selectors[22] = bytes4(0xc72d02e3);
        selectors[23] = bytes4(0x507cd8de);

        // 0xee6cf884,0x65cbd307,0xfa3c8dbf,0x92e67406,0x97436b5f,0x06350917,0x843b9e5d,0x71159fd1,0xcbe0f32e,0x4e583b31,
        // 0xa73a3e35,0x036787e5,0x46dbf572,0x32a7b732,0xc8b0d710,0x9b8ab684,0x3450191e,0x92b2bbae,0x97365b74,0xdfed4fcb,
        // 0x66ddd309,0x03e37464,0xc72d02e3,0x507cd8de
        _faceCut[0].functionSelectors = selectors;

        address _init = address(0);
        bytes memory _calldata = new bytes(0);
        // diamond.diamondCut(_faceCut, _init, _calldata);

        address[] memory facets = diamond.facetAddresses();
        console2.log("facets0 ", facets[0]);
        console2.log("facets1 ", facets[1]);
    }
}
