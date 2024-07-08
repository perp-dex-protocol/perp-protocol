// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "../types/ITradingCallbacks.sol";
import "../libraries/IUpdateLeverageUtils.sol";
import "../libraries/IUpdatePositionSizeUtils.sol";
import "../libraries/ITradingCommonUtils.sol";

/**
 * @dev Interface for GNSTradingCallbacks facet (inherits types and also contains functions, events, and custom errors)
 */
interface ITradingCallbacksUtils is
    ITradingCallbacks,
    IUpdateLeverageUtils,
    IUpdatePositionSizeUtils,
    ITradingCommonUtils
{
    /**
     *
     * @param _vaultClosingFeeP the % of closing fee going to vault
     */
    function initializeCallbacks(uint8 _vaultClosingFeeP) external;

    /**
     * @dev Update the % of closing fee going to vault
     * @param _valueP the % of closing fee going to vault
     */
    function updateVaultClosingFeeP(uint8 _valueP) external;

    /**
     * @dev Claim the pending gov fees for all collaterals
     */
    function claimPendingGovFees() external;

    /**
     * @dev Executes a pending open trade market order
     * @param _a the price aggregator answer (order id, price, etc.)
     */
    function openTradeMarketCallback(AggregatorAnswer memory _a) external;

    /**
     * @dev Executes a pending close trade market order
     * @param _a the price aggregator answer (order id, price, etc.)
     */
    function closeTradeMarketCallback(AggregatorAnswer memory _a) external;

    /**
     * @dev Executes a pending open trigger order (for limit/stop orders)
     * @param _a the price aggregator answer (order id, price, etc.)
     */
    function executeTriggerOpenOrderCallback(AggregatorAnswer memory _a) external;

    /**
     * @dev Executes a pending close trigger order (for tp/sl/liq orders)
     * @param _a the price aggregator answer (order id, price, etc.)
     */
    function executeTriggerCloseOrderCallback(AggregatorAnswer memory _a) external;

    /**
     * @dev Executes a pending update leverage order
     * @param _a the price aggregator answer (order id, price, etc.)
     */
    function updateLeverageCallback(AggregatorAnswer memory _a) external;

    /**
     * @dev Executes a pending increase position size market order
     * @param _a the price aggregator answer (order id, price, etc.)
     */
    function increasePositionSizeMarketCallback(AggregatorAnswer memory _a) external;

    /**
     * @dev Executes a pending decrease position size market order
     * @param _a the price aggregator answer (order id, price, etc.)
     */
    function decreasePositionSizeMarketCallback(AggregatorAnswer memory _a) external;

    /**
     * @dev Returns the current vaultClosingFeeP value (%)
     */
    function getVaultClosingFeeP() external view returns (uint8);

    /**
     * @dev Returns the current pending gov fees for a collateral index (collateral precision)
     */
    function getPendingGovFeesCollateral(uint8 _collateralIndex) external view returns (uint256);

    /**
     * @dev Emitted when vaultClosingFeeP is updated
     * @param valueP the % of closing fee going to vault
     */
    event VaultClosingFeePUpdated(uint8 valueP);

    /**
     * @dev Emitted when gov fees are claimed for a collateral
     * @param collateralIndex the collateral index
     * @param amountCollateral the amount of fees claimed (collateral precision)
     */
    event PendingGovFeesClaimed(uint8 collateralIndex, uint256 amountCollateral);

    /**
     * @dev Emitted when a market order is executed (open/close)
     * @param orderId the id of the corrsponding pending market order
     * @param t the trade object
     * @param open true for a market open order, false for a market close order
     * @param price the price at which the trade was executed (1e10 precision)
     * @param priceImpactP the price impact in percentage (1e10 precision)
     * @param percentProfit the profit in percentage (1e10 precision)
     * @param amountSentToTrader the final amount of collateral sent to the trader
     * @param collateralPriceUsd the price of the collateral in USD (1e8 precision)
     */
    // 1e8
    event MarketExecuted( // before fees
        ITradingStorage.Id orderId,
        ITradingStorage.Trade t,
        bool open,
        uint64 price,
        uint256 priceImpactP,
        int256 percentProfit,
        uint256 amountSentToTrader,
        uint256 collateralPriceUsd
    );

    /**
     * @dev Emitted when a limit/stop order is executed
     * @param orderId the id of the corresponding pending trigger order
     * @param t the trade object
     * @param triggerCaller the address that triggered the limit order
     * @param orderType the type of the pending order
     * @param price the price at which the trade was executed (1e10 precision)
     * @param priceImpactP the price impact in percentage (1e10 precision)
     * @param percentProfit the profit in percentage (1e10 precision)
     * @param amountSentToTrader the final amount of collateral sent to the trader
     * @param collateralPriceUsd the price of the collateral in USD (1e8 precision)
     * @param exactExecution true if guaranteed execution was used
     */
    event LimitExecuted( // 1e8
        ITradingStorage.Id orderId,
        ITradingStorage.Trade t,
        address indexed triggerCaller,
        ITradingStorage.PendingOrderType orderType,
        uint256 price,
        uint256 priceImpactP,
        int256 percentProfit,
        uint256 amountSentToTrader,
        uint256 collateralPriceUsd,
        bool exactExecution
    );

    /**
     * @dev Emitted when a pending market open order is canceled
     * @param orderId order id of the pending market open order
     * @param trader address of the trader
     * @param pairIndex index of the trading pair
     * @param cancelReason reason for the cancelation
     */
    event MarketOpenCanceled(
        ITradingStorage.Id orderId, address indexed trader, uint256 indexed pairIndex, CancelReason cancelReason
    );

    /**
     * @dev Emitted when a pending market close order is canceled
     * @param orderId order id of the pending market close order
     * @param trader address of the trader
     * @param pairIndex index of the trading pair
     * @param index index of the trade for trader
     * @param cancelReason reason for the cancelation
     */
    event MarketCloseCanceled(
        ITradingStorage.Id orderId,
        address indexed trader,
        uint256 indexed pairIndex,
        uint256 index,
        CancelReason cancelReason
    );

    /**
     * @dev Emitted when a pending trigger order is canceled
     * @param orderId order id of the pending trigger order
     * @param triggerCaller address of the trigger caller
     * @param orderType type of the pending trigger order
     * @param cancelReason reason for the cancelation
     */
    event TriggerOrderCanceled(
        ITradingStorage.Id orderId,
        address indexed triggerCaller,
        ITradingStorage.PendingOrderType orderType,
        CancelReason cancelReason
    );

    /**
     *
     * @param trader address of the trader
     * @param collateralIndex index of the collateral
     * @param amountCollateral amount charged (collateral precision)
     */
    event BorrowingFeeCharged(address indexed trader, uint8 indexed collateralIndex, uint256 amountCollateral);
}
