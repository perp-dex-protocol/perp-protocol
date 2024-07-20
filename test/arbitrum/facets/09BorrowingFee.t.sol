// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {BasicScriptTest} from "../BasicScriptTest.t.sol";
import {GNSPairsStorage} from "src/core/facets/GNSPairsStorage.sol";
import {GNSBorrowingFees} from "src/core/facets/GNSBorrowingFees.sol";
import {GNSTradingStorage} from "src/core/facets/GNSTradingStorage.sol";
import {ITradingStorage} from "src/interfaces/types/ITradingStorage.sol";
import {IPairsStorage} from "src/interfaces/types/IPairsStorage.sol";

contract BorrowingFeeTest is BasicScriptTest {
    // 1. getPairOiCollateral
    // 2. getPairMaxOiCollateral
    // 3. withinMaxBorrowingGroupOi

    // 1. pairOicollateral+ posSizeCollateral <= pairMaxOiCollateral
    // 2. withIn max borrowing groupOi

    GNSPairsStorage pairsStorage = GNSPairsStorage(payable(0xFF162c694eAA571f685030649814282eA457f169));
    GNSBorrowingFees borrowingFee = GNSBorrowingFees(payable(0xFF162c694eAA571f685030649814282eA457f169));
    GNSTradingStorage tradingStorage = GNSTradingStorage(payable(0xFF162c694eAA571f685030649814282eA457f169));

    function testBorrowingFeesParams() public {
        uint8 collaterIndex = 3;
        uint16 pairIndex = 1;
        bool long = true;

        uint256 pairoiCollateral = borrowingFee.getPairOiCollateral(collaterIndex, pairIndex, long);
        console2.logUint(pairoiCollateral);

        uint256 pairMaxOiCollateral = borrowingFee.getPairMaxOiCollateral(collaterIndex, pairIndex);
        console2.log(pairMaxOiCollateral);

        bool withinMaxBorrowingGroupOi = borrowingFee.withinMaxBorrowingGroupOi(collaterIndex, pairIndex, long, 100e18);
        console2.log(withinMaxBorrowingGroupOi);

        // _setBorrowingPairParams
        // _updatePairOi
    }

    // collateral 1 DAI  0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1
    // collateral 2 WETH 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1
    // collateral 3 USDC 0xaf88d065e77c8cC2239327C5EDb3A432268e5831

    // ITradingStorage.Collateral memory collateral1 = tradingStorage.getCollateral(4);
    // console2.log(collateral1.collateral);

    // pair 0 BTC/USD
    // pair 1 ETH/USD
    // pair 2 LINK/USD
    // pair 3 DOGE/USD
    // pair 60 GooGL/USD

    // IPairsStorage.Pair memory pair = pairsStorage.pairs(100);
    // console2.log(pair.from, '/', pair.to);
}
