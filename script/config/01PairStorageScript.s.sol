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
        // updateFeeData();
        // addGroupData();
        addPair();

        // IPairsStorage.Fee memory fee0 = pairsStorage.fees(0);
        // console2.log(fee0.name);
        // console2.log(fee0.openFeeP);
        // console2.log(fee0.closeFeeP);
        // console2.log(fee0.oracleFeeP);
        // console2.log(fee0.triggerOrderFeeP);
        // console2.log(fee0.minPositionSizeUsd);

        // IPairsStorage.Group memory group0 = pairsStorage.groups(0);
        // console2.log(group0.name);
        // console2.logBytes32(group0.job);
        // console2.log(group0.minLeverage);
        // console2.log(group0.maxLeverage);

        IPairsStorage.Pair memory pair0 = pairsStorage.pairs(0);
        console2.log("Pair from: %s", pair0.from);
        console2.log("Pair to: %s", pair0.to);
        console2.log("Spread: %d", pair0.spreadP);
        console2.log("groupIndex: %d", pair0.groupIndex);
        console2.log("feeIndex: %d", pair0.feeIndex);
        console2.log("feed1 address: %s", pair0.feed.feed1);
        console2.log("feed2 address: %s", pair0.feed.feed2);
        console2.log("feedCalculation: %d", uint256(pair0.feed.feedCalculation));
        console2.log("maxDeviationP: %d", pair0.feed.maxDeviationP);

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

    function updateFeeData() public {
        IPairsStorage.Fee[] memory fees = new IPairsStorage.Fee[](1);

        IPairsStorage.Fee memory fee =
            IPairsStorage.Fee("crypto", 300000000, 600000000, 40000000, 200000000, 100000000000000000000);

        uint256[] memory _ids = new uint256[](1);
        _ids[0] = 0;

        fees[0] = fee;

        pairsStorage.updateFees(_ids, fees);
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
        IPairsStorage.Pair[] memory pairs = new IPairsStorage.Pair[](1);

        IPairsStorage.Pair memory pair = IPairsStorage.Pair(
            "ETH",
            "USD",
            IPairsStorage.Feed(
                0x5046Bf1ccf10Ff4C0Dd7780c8AddEAbfa9a85E1D,
                0x0000000000000000000000000000000000000000,
                IPairsStorage.FeedCalculation.DEFAULT,
                200000000000
            ),
            0,
            0,
            0
        );
        pairs[0] = pair;
        pairsStorage.addPairs(pairs);
    }
}
