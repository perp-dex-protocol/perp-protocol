// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";
import {GNSAddressStore} from "src/core/abstract/GNSAddressStore.sol";
import {IGNSDiamondLoupe} from "src/interfaces/IGNSDiamondLoupe.sol";

import {
    TransparentUpgradeableProxy,
    ITransparentUpgradeableProxy
} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract DiamondProxyDeployer is BaseScriptDeployer {
    address proxyAdmin = 0xDe1D7C9f36A0d36e24f8F7D923237616c0FB5B09;
    address user_address = 0x5557bc35b36f3d92Af1A1224b1e090f6Dd5b00CE;

    address proxy_address = 0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6;

    function run() public {
        // 1. deploy a new Impl
        GNSMultiCollatDiamond diamondProxyImpl = new GNSMultiCollatDiamond();
        console2.log("diamondProxyImpl", address(diamondProxyImpl));

        // 2. upgrade Impl
        ProxyAdmin(proxyAdmin).upgrade(ITransparentUpgradeableProxy(proxy_address), address(diamondProxyImpl));

        // 3. execute remove logic

        // bytes memory data = abi.encodeWithSelector(GNSAddressStore.initialize.selector, user_address);

        // GNSMultiCollatDiamond diamondProxy = GNSMultiCollatDiamond(
        //     payable(
        //         address(
        //             new TransparentUpgradeableProxy(address(new GNSMultiCollatDiamond()), address(proxyAdmin), data)
        //         )
        //     )
        // );
        // console2.log("diamondProxy", address(diamondProxy));

        // GNSMultiCollatDiamond diamond = GNSMultiCollatDiamond(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));
        // IGNSDiamondLoupe.Facet[] memory facets = diamond.facets();

        // console2.log("facets", facets.length);

        // for (uint256 i = 0; i < facets.length; i++) {
        //     console2.log("facets", i, facets[i].facetAddress);

        //     for (uint256 j = 0; j < facets[i].functionSelectors.length; j++) {
        //         console2.logBytes4(facets[i].functionSelectors[j]);
        //     }
        // }
    }
}
