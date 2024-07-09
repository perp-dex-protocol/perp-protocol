// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSReferrals} from "src/core/facets/GNSReferrals.sol";

contract GNSReferralsScript is BaseScriptDeployer {
    function run() public {
        GNSReferrals referrals = new GNSReferrals();
        console2.log("referrals", address(referrals));
    }
}
