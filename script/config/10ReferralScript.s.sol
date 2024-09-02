// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSReferrals} from "src/core/facets/GNSReferrals.sol";
import {IReferrals} from "src/interfaces/types/IReferrals.sol";

contract GNSReferralsScript is BaseScriptDeployer {
    GNSReferrals referral = GNSReferrals(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));
    address user_address = 0x5557bc35b36f3d92Af1A1224b1e090f6Dd5b00CE;

    function run() public {
        // initializeReferral();
        // getReferralParam();

        // whiteListReferral();

        IReferrals.ReferrerDetails memory referrerDetails = referral.getReferrerDetails(0xB883052a380F0c13958cbE309d702060D76Df2EF);
        // console2.log(referrerDetails.ally);
        // console2.log(referrerDetails.volumeReferredUsd);
        for (uint256 i = 0; i < referrerDetails.tradersReferred.length; i++) {
            console2.log(referrerDetails.tradersReferred[i]);
        }

        // console2.log(referral.getTraderLastReferrer(user_address));
    }

    function initializeReferral() public {
        // referral.initializeReferrals(10, 75, 33, 10000000);

        referral.updateAllyFeeP(10);
        referral.updateReferralsOpenFeeP(33);
        referral.updateStartReferrerFeeP(75);
        referral.updateReferralsTargetVolumeUsd(10000000);
    }

    function getReferralParam() public view {
        uint256 allyFeep = referral.getReferralsAllyFeeP();
        console2.log(allyFeep);

        uint256 openFeep = referral.getReferralsOpenFeeP();
        console2.log(openFeep);

        uint256 startReferrerFeep = referral.getReferralsStartReferrerFeeP();
        console2.log(startReferrerFeep);

        uint256 targetVolumeUsd = referral.getReferralsTargetVolumeUsd();
        console2.log(targetVolumeUsd);
    }


    function whiteListReferral() public{

        address[] memory referrals = new address[](1);
        referrals[0] = 0xB883052a380F0c13958cbE309d702060D76Df2EF; 

        address[] memory allies = new address[](1);
        allies[0] = address(0);
        referral.whitelistReferrers(referrals, allies);
    }

}
