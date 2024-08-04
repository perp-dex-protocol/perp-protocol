// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";

interface IWSEI {
    function withdraw(uint256 wad) external;
    function balanceOf(address account) external view returns (uint256);
    function deposit() external payable;
}

contract WSeiWithdrawScript is BaseScriptDeployer {
    IWSEI wsei = IWSEI(0xE30feDd158A2e3b13e9badaeABaFc5516e95e8C7);
    address user_address = 0x5557bc35b36f3d92Af1A1224b1e090f6Dd5b00CE;

    function run() public {
        IWSEI(wsei).deposit{value: 5 ether}();

        // wsei.withdraw(wsei.balanceOf(user_address));
    }
}
