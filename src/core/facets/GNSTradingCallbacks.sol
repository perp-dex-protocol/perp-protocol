// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "../abstract/GNSAddressStore.sol";

import "../../interfaces/libraries/ITradingCallbacksUtils.sol";
import "../../interfaces/types/ITradingStorage.sol";

import "../../libraries/TradingCallbacksUtils.sol";

/**
 * @dev Facet #8: Callbacks (to execute actions after receiving median price from price aggregator)
 */
contract GNSTradingCallbacks is GNSAddressStore, ITradingCallbacksUtils {
    // Initialization

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @inheritdoc ITradingCallbacksUtils
    function initializeCallbacks(uint8 _vaultClosingFeeP) external reinitializer(9) {
        TradingCallbacksUtils.initializeCallbacks(_vaultClosingFeeP);
    }

    // Management Setters

    /// @inheritdoc ITradingCallbacksUtils
    function updateVaultClosingFeeP(uint8 _valueP) external onlyRole(Role.GOV) {
        TradingCallbacksUtils.updateVaultClosingFeeP(_valueP);
    }

    /// @inheritdoc ITradingCallbacksUtils
    function claimPendingGovFees() external onlyRole(Role.GOV) {
        TradingCallbacksUtils.claimPendingGovFees();
    }

    // Interactions

    /// @inheritdoc ITradingCallbacksUtils
    function openTradeMarketCallback(AggregatorAnswer memory _a) external virtual onlySelf {
        TradingCallbacksUtils.openTradeMarketCallback(_a);
    }

    /// @inheritdoc ITradingCallbacksUtils
    function closeTradeMarketCallback(AggregatorAnswer memory _a) external virtual onlySelf {
        TradingCallbacksUtils.closeTradeMarketCallback(_a);
    }

    /// @inheritdoc ITradingCallbacksUtils
    function executeTriggerOpenOrderCallback(AggregatorAnswer memory _a) external virtual onlySelf {
        TradingCallbacksUtils.executeTriggerOpenOrderCallback(_a);
    }

    /// @inheritdoc ITradingCallbacksUtils
    function executeTriggerCloseOrderCallback(AggregatorAnswer memory _a) external virtual onlySelf {
        TradingCallbacksUtils.executeTriggerCloseOrderCallback(_a);
    }

    // Getters

    /// @inheritdoc ITradingCallbacksUtils
    function getVaultClosingFeeP() external view returns (uint8) {
        return TradingCallbacksUtils.getVaultClosingFeeP();
    }

    /// @inheritdoc ITradingCallbacksUtils
    function getPendingGovFeesCollateral(uint8 _collateralIndex) external view returns (uint256) {
        return TradingCallbacksUtils.getPendingGovFeesCollateral(_collateralIndex);
    }

    /// @inheritdoc ITradingCallbacksUtils
    function updateLeverageCallback(AggregatorAnswer memory _a) external virtual onlySelf {
        TradingCallbacksUtils.updateLeverageCallback(_a);
    }

    /// @inheritdoc ITradingCallbacksUtils
    function increasePositionSizeMarketCallback(AggregatorAnswer memory _a) external virtual onlySelf {
        TradingCallbacksUtils.increasePositionSizeMarketCallback(_a);
    }

    /// @inheritdoc ITradingCallbacksUtils
    function decreasePositionSizeMarketCallback(AggregatorAnswer memory _a) external virtual onlySelf {
        TradingCallbacksUtils.decreasePositionSizeMarketCallback(_a);
    }
}
