// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";
import {IAddressStore} from "src/interfaces/types/IAddressStore.sol";

contract RolesScript is BaseScriptDeployer {
    GNSMultiCollatDiamond diamond = GNSMultiCollatDiamond(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

    address user_address = 0x5557bc35b36f3d92Af1A1224b1e090f6Dd5b00CE;

    function run() public {
        address[] memory _accounts = new address[](1);
        _accounts[0] = user_address;

        IAddressStore.Role[] memory _roles = new IAddressStore.Role[](1);
        _roles[0] = IAddressStore.Role.MANAGER;

        bool[] memory _values = new bool[](1);
        _values[0] = true;

        diamond.setRoles(_accounts, _roles, _values);

        bool hasRole = diamond.hasRole(user_address, IAddressStore.Role.MANAGER);
        console2.log("has role ", hasRole);
    }
}
