// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {GNSPairsStorage} from "src/core/facets/GNSPairsStorage.sol";
import {IPairsStorage} from "src/interfaces/types/IPairsStorage.sol";
import {IAddressStore} from "src/interfaces/types/IAddressStore.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {GNSAddressStore} from "src/core/abstract/GNSAddressStore.sol";

contract Facet1_PairStorageTest is Test {
    address Alice = makeAddr("Alice");

    ProxyAdmin proxyAdmin;
    GNSPairsStorage pairsStorage;

    function setUp() public {
        vm.createSelectFork("https://evm-rpc.sei-apis.com");
        vm.startPrank(Alice, Alice);
        proxyAdmin = new ProxyAdmin();
        pairsStorage = new GNSPairsStorage();
        vm.stopPrank();
    }


    function test() public {
        vm.startPrank(Alice, Alice);
        bytes memory data = abi.encodeWithSelector(GNSAddressStore.initialize.selector, Alice);

        GNSPairsStorage pairsStorageProxy = GNSPairsStorage(address( new TransparentUpgradeableProxy(address(pairsStorage), address(proxyAdmin), data) ));

        console2.log("pairsStorageProxy", address(pairsStorageProxy));


        address[] memory accounts = new address[](1);
        accounts[0] = Alice;

        IAddressStore.Role[] memory roles = new IAddressStore.Role[](1);
        roles[0] = IAddressStore.Role.GOV;

        bool[] memory values = new bool[](1);

        pairsStorageProxy.setRoles(accounts, roles, values);


        // IPairsStorage.Pair[] memory pairs = new IPairsStorage.Pair[](1);
        // pairs[0] = IPairsStorage.Pair(
        //     "ETH", "USD", IPairsStorage.Feed(address(0), address(0), IPairsStorage.FeedCalculation.DEFAULT, 0), 0, 0, 0
        // );

        // pairsStorage.addPairs(pairs);
    }
}
