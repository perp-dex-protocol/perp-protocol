// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSTradingStorage} from "src/core/facets/GNSTradingStorage.sol";
import {ITradingStorage} from "src/interfaces/types/ITradingStorage.sol";
import {IAddressStore} from "src/interfaces/types/IAddressStore.sol";

contract TradingStorageScript is BaseScriptDeployer {
    GNSTradingStorage tradingStorage = GNSTradingStorage(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

    address fore_token = 0x7b34E269c615Dd2842b7AA5C513f5ebcaea5b70d;
    address seiStaking = 0x7f54BeCa8FA5908355a0B613C425484B70c58167;

    function run() public {
        // 1. update trading storage activated status
        // tradingStorage.updateTradingActivated(ITradingStorage.TradingActivated.ACTIVATED);

        ITradingStorage.TradingActivated activated = tradingStorage.getTradingActivated();
        console2.log("Trading activated status: {}", uint256(activated));
        // getCollateralsCount()
        uint8 collateralsCount = tradingStorage.getCollateralsCount();
        console2.log("Collaterals count: {}", collateralsCount);

        // 2. initialize trading
        // tradingStorage.initializeTradingStorage(fore_token, seiStaking, new address[](0), new address[](0));
        // IAddressStore.Addresses memory addrs = tradingStorage.getAddresses();
        // console2.log("GNS address: {}", addrs.gns);
        // console2.log("GNS Staking address: {}", addrs.gnsStaking);

        // 3. add gtoken market
        address wsei = 0xE30feDd158A2e3b13e9badaeABaFc5516e95e8C7;
        address fsei = 0x267Ff9020A31c7dece29407Abb0C17F8bF83485E;

        // tradingStorage.addCollateral(wsei, fsei);

        collateralsCount = tradingStorage.getCollateralsCount();
        console2.log("Collaterals count: {}", collateralsCount);

        //      struct Collateral {
        //     // slot 1
        //     address collateral; // 160 bits
        //     bool isActive; // 8 bits
        //     uint88 __placeholder; // 88 bits
        //     // slot 2
        //     uint128 precision;
        //     uint128 precisionDelta;
        // }
        ITradingStorage.Collateral memory collateral1 = tradingStorage.getCollateral(1);
        console2.log("Collateral 1: {}", collateral1.collateral);
        console2.log("Collateral 1: {}", collateral1.isActive);
        console2.log("Collateral 1: {}", collateral1.precision);
        console2.log("Collateral 1: {}", collateral1.precisionDelta);
    }
}
