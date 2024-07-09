// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";
import {GNSAddressStore} from "src/core/abstract/GNSAddressStore.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract DiamondProxyDeployer is BaseScriptDeployer {
    address proxyAdmin = 0xDe1D7C9f36A0d36e24f8F7D923237616c0FB5B09;
    address user_address = 0x5557bc35b36f3d92Af1A1224b1e090f6Dd5b00CE;

    function run() public {
        // GNSMultiCollatDiamond diamondProxyImpl = new GNSMultiCollatDiamond();
        // console2.log("diamondProxyImpl", address(diamondProxyImpl));

        bytes memory data = abi.encodeWithSelector(GNSAddressStore.initialize.selector, user_address);

        GNSMultiCollatDiamond diamondProxy = GNSMultiCollatDiamond(
            payable(
                address(
                    new TransparentUpgradeableProxy(address(new GNSMultiCollatDiamond()), address(proxyAdmin), data)
                )
            )
        );
        console2.log("diamondProxy", address(diamondProxy));
    }
}
