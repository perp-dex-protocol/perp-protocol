// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {MultiCall} from "../multicall/Multicall.sol";

contract MulticallContractScript is BaseScriptDeployer {
    MultiCall multicallContract = MultiCall(0x4D24B5C384C15ab4542DB58b200e45eE234FaEDE);

    function run() public {
        MultiCall.Call[] memory calls = new MultiCall.Call[](2);

        address proxy = 0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6;

        calls[0] = MultiCall.Call(proxy, abi.encodeWithSignature("closeTradeMarket(uint32)", 16));
        calls[1] = MultiCall.Call(proxy, abi.encodeWithSignature("closeTradeMarket(uint32)", 17));

        multicallContract.aggregate(calls);
    }
}
