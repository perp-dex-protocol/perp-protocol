// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {BasicScriptTest} from "../BasicScriptTest.t.sol";
import {GNSReferrals} from "src/core/facets/GNSReferrals.sol";

contract ReferralTest is BasicScriptTest {
    address diamondcontract = 0xFF162c694eAA571f685030649814282eA457f169;
    GNSReferrals referral = GNSReferrals(diamondcontract);

    function testGetReferralsAllyFeeP() public view {
        uint256 allyFeeP = referral.getReferralsAllyFeeP();
        console2.logUint(allyFeeP);

        // getReferralsStartReferrerFeeP
        uint256 startReferrerFeeP = referral.getReferralsStartReferrerFeeP();
        console2.logUint(startReferrerFeeP);

        // getReferralsOpenFeeP
        uint256 openFeeP = referral.getReferralsOpenFeeP();
        console2.logUint(openFeeP);
    }
}
