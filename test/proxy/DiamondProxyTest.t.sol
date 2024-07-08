// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";
import {GNSAddressStore} from "src/core/abstract/GNSAddressStore.sol";
import {GNSPairsStorage} from "src/core/facets/GNSPairsStorage.sol";
import {IAddressStore} from "src/interfaces/types/IAddressStore.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {IDiamondStorage} from "src/interfaces/types/IDiamondStorage.sol";

contract DiamondProxyTest is Test {
    address Alice = makeAddr("Alice");
    GNSMultiCollatDiamond diamondProxy;
    ProxyAdmin proxyAdmin; //= ProxyAdmin(0xDe1D7C9f36A0d36e24f8F7D923237616c0FB5B09);

    GNSPairsStorage pairStoreProxy;

    function setUp() public {
        // vm.createSelectFork("https://evm-rpc.sei-apis.com");

        vm.startPrank(Alice, Alice);
        proxyAdmin = new ProxyAdmin();
        GNSMultiCollatDiamond diamondImpl = new GNSMultiCollatDiamond();
        bytes memory data = abi.encodeWithSelector(GNSAddressStore.initialize.selector, Alice);
        diamondProxy = GNSMultiCollatDiamond(
            payable(address(new TransparentUpgradeableProxy(address(diamondImpl), address(proxyAdmin), data)))
        );

        GNSPairsStorage pairStoreImpl = new GNSPairsStorage();
        pairStoreProxy = GNSPairsStorage(
            payable(address(new TransparentUpgradeableProxy(address(pairStoreImpl), address(proxyAdmin), data)))
        );

        console2.log("pairStoreProxy", address(pairStoreProxy));

        vm.stopPrank();
    }

    function testAddNewFacet() public {
        // 1. create a facet
        vm.startPrank(Alice, Alice);

        // 2. diamondcut the facet
        IDiamondStorage.FacetCut[] memory _faceCuts = new IDiamondStorage.FacetCut[](1);

        bytes4 selector = 0xdb7c3f9d;
        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = selector;

        IDiamondStorage.FacetCut memory _faceCut = IDiamondStorage.FacetCut({
            facetAddress: address(pairStoreProxy),
            action: IDiamondStorage.FacetCutAction.ADD,
            functionSelectors: selectors
        });
        _faceCuts[0] = _faceCut;

        address _init = address(0);
        bytes memory _calldata = new bytes(0);
        diamondProxy.diamondCut(_faceCuts, _init, _calldata);

        // 3. query all facets
        address[] memory facetAddresses = diamondProxy.facetAddresses();
        console2.log("facetAddresses", facetAddresses[0]);
    }
}
