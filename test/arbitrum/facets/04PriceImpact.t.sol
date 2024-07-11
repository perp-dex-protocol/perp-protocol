// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {BasicScriptTest} from "../BasicScriptTest.t.sol";
import {IAddressStore} from "src/interfaces/types/IAddressStore.sol";
import {GNSPriceImpact} from "src/core/facets/GNSPriceImpact.sol";
import {IPriceImpact} from "src/interfaces/types/IPriceImpact.sol";

contract PriceImpactTest is BasicScriptTest {
    address diamondcontract = 0xFF162c694eAA571f685030649814282eA457f169;
    GNSPriceImpact priceImpact = GNSPriceImpact(diamondcontract);

    address user_address = 0x7d6e74D0C1298Cb8A5DF19EA8899a9A73E46c241;

    address manager_address = 0xE72DfEC45cCc0B5571D659Cb8B482523C45439dB;

    // function testHasRole() public view {
    //     bool result = priceImpact.hasRole(manager_address, IAddressStore.Role.MANAGER);
    //     console2.log(result);
    // }

    // function testGetOiWindowsSettings() public view {
    //     IPriceImpact.OiWindowsSettings memory oiWindowsSettings = priceImpact.getOiWindowsSettings();
    //     console2.log(oiWindowsSettings.startTs);
    //     console2.log(oiWindowsSettings.windowsDuration);
    //     console2.log(oiWindowsSettings.windowsCount);
    // }

    // function testGetTraderInfo() public view{
    //     uint128 last0 = priceImpact.getTradeLastWindowOiUsd(user_address, 0);
    //     console2.log(last0);

    //     uint128 last1 = priceImpact.getTradeLastWindowOiUsd(user_address, 1);
    //     console2.log(last1);
    // }

    function testGetPairDepth() public view {
        IPriceImpact.PairDepth memory depth = priceImpact.getPairDepth(133);
        console2.log(depth.onePercentDepthAboveUsd);
        console2.log(depth.onePercentDepthBelowUsd);
    }
}
