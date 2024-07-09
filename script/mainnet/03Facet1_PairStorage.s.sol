// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSPairsStorage} from "src/core/facets/GNSPairsStorage.sol";
import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";
import {IDiamondStorage} from "src/interfaces/types/IDiamondStorage.sol";
import {IAddressStore} from "src/interfaces/types/IAddressStore.sol";
import {IPairsStorage} from "src/interfaces/types/IPairsStorage.sol";

contract PairStorageScript is BaseScriptDeployer {
    address user_address = 0x5557bc35b36f3d92Af1A1224b1e090f6Dd5b00CE;

    function run() public {
        // 1. deploy facet
        // GNSPairsStorage pairStorage = new GNSPairsStorage();
        // console2.log("pairStorage", address(pairStorage));

        // 2. add diamond cut
        GNSMultiCollatDiamond diamond = GNSMultiCollatDiamond(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

        IDiamondStorage.FacetCut[] memory _faceCut = new IDiamondStorage.FacetCut[](1);
        _faceCut[0].facetAddress = address(0xDFB881D25c9716AB4Ea7C721136D11E71c4F0028);
        _faceCut[0].action = IDiamondStorage.FacetCutAction.ADD;
        bytes4[] memory selectors = new bytes4[](28);

        selectors[0] = bytes4(0x0c00b94a);
        selectors[1] = bytes4(0x60283cba);
        selectors[2] = bytes4(0xdb7c3f9d);
        selectors[3] = bytes4(0x4acc79ed);
        selectors[4] = bytes4(0x658de48a);
        selectors[5] = bytes4(0x678b3fb0);
        selectors[6] = bytes4(0x96324bd4);
        selectors[7] = bytes4(0x885e2750);
        selectors[8] = bytes4(0x281b7ead);
        selectors[9] = bytes4(0x1628bfeb);
        selectors[10] = bytes4(0x836a341a);
        selectors[11] = bytes4(0x24a96865);
        selectors[12] = bytes4(0x302f81fc);
        selectors[13] = bytes4(0x281b693c);
        selectors[14] = bytes4(0x59a992d0);
        selectors[15] = bytes4(0x5e26ff4e);
        selectors[16] = bytes4(0x8251135b);
        selectors[17] = bytes4(0xf7acbabd);
        selectors[18] = bytes4(0xa1d54e9b);
        selectors[19] = bytes4(0xe74aff72);
        selectors[20] = bytes4(0xb91ac788);
        selectors[21] = bytes4(0x9567dccf);
        selectors[22] = bytes4(0xb81b2b71);
        selectors[23] = bytes4(0xd79261fd);
        selectors[24] = bytes4(0xe57f6759);
        selectors[25] = bytes4(0x11d79ef5);
        selectors[26] = bytes4(0x10efa5d5);
        selectors[27] = bytes4(0x8078bfbe);

        _faceCut[0].functionSelectors = selectors;

        address _init = address(0);
        bytes memory _calldata = new bytes(0);
        // diamond.diamondCut(_faceCut, _init, _calldata);

        // 3. query facets
        address[] memory facets = diamond.facetAddresses();
        console2.log("facets", facets[0]);

        // 4. set rules
        address[] memory _accounts = new address[](1);
        _accounts[0] = address(user_address);

        IAddressStore.Role[] memory _roles = new IAddressStore.Role[](1);
        _roles[0] = IAddressStore.Role.GOV;

        bool[] memory _values = new bool[](1);
        _values[0] = true;

        diamond.setRoles(_accounts, _roles, _values);

        // 5. add pairs
        // add pairs
        GNSPairsStorage pairStorage = GNSPairsStorage(address(diamond));

        // add groups
        // GNSPairsStorage.Group[] memory _groups = new GNSPairsStorage.Group[](1);
        // _groups[0] = IPairsStorage.Group("default", bytes32(0), 3, 1000);
        // pairStorage.addGroups(_groups);

        // GNSPairsStorage.Pair[] memory _pairs = new GNSPairsStorage.Pair[](1);
        // _pairs[0] = IPairsStorage.Pair(
        //     "ETH", "USD", IPairsStorage.Feed(address(0), address(0), IPairsStorage.FeedCalculation.DEFAULT, 0), 0, 0, 0
        // );
        // pairStorage.addPairs(_pairs);
    }
}
