// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {BaseScriptDeployer} from "../BaseScript.s.sol";
import {GNSMultiCollatDiamond} from "src/core/GNSMultiCollatDiamond.sol";
import {GNSPairsStorage} from "src/core/facets/GNSPairsStorage.sol";
import {IPairsStorage} from "src/interfaces/types/IPairsStorage.sol";
import {IDiamondStorage} from "src/interfaces/types/IDiamondStorage.sol";

contract PairStorageAddRemoveScript is BaseScriptDeployer {
    GNSPairsStorage pairsStorage = GNSPairsStorage(payable(0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6));

    function run() public {
        console2.log(pairsStorage.feesCount());
        console2.log(pairsStorage.groupsCount());
        console2.log(pairsStorage.pairsCount());

        // addFeeData();
        addGroupData();
        // addPair();

        console2.log(pairsStorage.feesCount());
        console2.log(pairsStorage.groupsCount());
        console2.log(pairsStorage.pairsCount());
    }

    // 1. add fee
    function addFeeData() public {
        // {
        //   "name": "crypto",
        // 1e10 -> 0.03%
        //   "openFeeP": "300000000",
        // 1e10 -> 0.06%
        //   "closeFeeP": "600000000",
        // 1e10 -> 0.004%
        //   "oracleFeeP": "40000000",
        // 0.02%
        //   "triggerOrderFeeP": "200000000",
        //5000U
        //   "minPositionSizeUsd": "5000000000000000000000"
        // }
        IPairsStorage.Fee[] memory fees = new IPairsStorage.Fee[](1);

        IPairsStorage.Fee memory fee =
            IPairsStorage.Fee("crypto", 300000000, 600000000, 40000000, 200000000, 5000000000000000000000);
        fees[0] = fee;

        pairsStorage.addFees(fees);
    }

    // 2.add group
    function addGroupData() public {
        // {
        //   "name": "crypto",
        //   "job": "0x3430623930323466393363393430326238353736633533636638643938653763",
        //   "minLeverage": "2",
        //   "maxLeverage": "150"
        // }

        IPairsStorage.Group[] memory groups = new IPairsStorage.Group[](1);

        IPairsStorage.Group memory group =
            IPairsStorage.Group("crypto", 0x3430623930323466393363393430326238353736633533636638643938653763, 2, 150);
        groups[0] = group;

        pairsStorage.addGroups(groups);
    }

    // 3. add pair
    function addPair() public {
        //  {
        //   "from": "BTC",
        //   "to": "USD",
        //   "feed": {
        //     "feed1": "0x6ce185860a4963106506C203335A2910413708e9",
        //     "feed2": "0x0000000000000000000000000000000000000000",
        //     "feedCalculation": 0,
        //     "maxDeviationP": "200000000000"
        //   },
        //   "spreadP": "0",
        //   "groupIndex": "0",
        //   "feeIndex": "0"
        // }

        IPairsStorage.Pair[] memory pairs = new IPairsStorage.Pair[](1);

        IPairsStorage.Pair memory pair = IPairsStorage.Pair(
            "BTC",
            "USD",
            IPairsStorage.Feed(
                0x6ce185860a4963106506C203335A2910413708e9,
                0x0000000000000000000000000000000000000000,
                IPairsStorage.FeedCalculation.COMBINE,
                200000000000
            ),
            0,
            0,
            0
        );

        pairsStorage.addPairs(pairs);
    }
}
