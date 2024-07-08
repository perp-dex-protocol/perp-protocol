// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "../../interfaces/IGNSMultiCollatDiamond.sol";

import "../TradingCommonUtils.sol";

/**
 *
 * @dev This is an external library for leverage update lifecycles
 * @dev Used by GNSTrading and GNSTradingCallbacks facets
 */
library UpdateLeverageLifecycles {
    /**
     * @dev Initiate update leverage order, done in 2 steps because need to cancel if liquidation price reached
     * @param _input request decrease leverage input
     */
    function requestUpdateLeverage(IUpdateLeverageUtils.UpdateLeverageInput memory _input) external {
        // 1. Request validation
        (ITradingStorage.Trade memory trade, bool isIncrease, uint256 collateralDelta) = _validateRequest(_input);

        // 2. If decrease leverage, transfer collateral delta to diamond
        if (!isIncrease) TradingCommonUtils.transferCollateralFrom(trade.collateralIndex, trade.user, collateralDelta);

        // 3. Create pending order and make price aggregator request
        ITradingStorage.Id memory orderId = _initiateRequest(trade, _input.newLeverage, collateralDelta);

        emit IUpdateLeverageUtils.LeverageUpdateInitiated(
            orderId, _input.user, trade.pairIndex, _input.index, isIncrease, _input.newLeverage
        );
    }

    /**
     * @dev Execute update leverage callback
     * @param _order pending order struct
     * @param _answer price aggregator request answer
     */
    function executeUpdateLeverage(
        ITradingStorage.PendingOrder memory _order,
        ITradingCallbacks.AggregatorAnswer memory _answer
    ) external {
        // 1. Prepare values
        ITradingStorage.Trade memory pendingTrade = _order.trade;
        ITradingStorage.Trade memory existingTrade =
            _getMultiCollatDiamond().getTrade(pendingTrade.user, pendingTrade.index);
        bool isIncrease = pendingTrade.leverage > existingTrade.leverage;

        // 2. Refresh trader fee tier cache
        TradingCommonUtils.updateFeeTierPoints(
            existingTrade.collateralIndex, existingTrade.user, existingTrade.pairIndex, 0
        );

        // 3. Prepare useful values
        IUpdateLeverageUtils.UpdateLeverageValues memory values =
            _prepareCallbackValues(existingTrade, pendingTrade, isIncrease);

        // 4. Callback validation
        ITradingCallbacks.CancelReason cancelReason = _validateCallback(existingTrade, values, _answer);

        // 5. If trade exists, charge gov fee and update trade
        if (cancelReason != ITradingCallbacks.CancelReason.NO_TRADE) {
            // 5.1 Distribute gov fee
            TradingCommonUtils.distributeExactGovFeeCollateral(
                existingTrade.collateralIndex,
                existingTrade.user,
                values.govFeeCollateral // use min fee / 2
            );

            // 5.2 Handle callback (update trade in storage, remove gov fee OI, handle collateral delta transfers)
            _handleCallback(existingTrade, pendingTrade, values, cancelReason, isIncrease);
        }

        // 6. Close pending update leverage order
        _getMultiCollatDiamond().closePendingOrder(_answer.orderId);

        emit IUpdateLeverageUtils.LeverageUpdateExecuted(
            _answer.orderId,
            isIncrease,
            cancelReason,
            existingTrade.collateralIndex,
            existingTrade.user,
            existingTrade.pairIndex,
            existingTrade.index,
            _answer.price,
            pendingTrade.collateralAmount,
            values
        );
    }

    /**
     * @dev Returns current address as multi-collateral diamond interface to call other facets functions.
     */
    function _getMultiCollatDiamond() internal view returns (IGNSMultiCollatDiamond) {
        return IGNSMultiCollatDiamond(address(this));
    }

    /**
     * @dev Returns new trade collateral amount based on new leverage (collateral precision)
     * @param _existingCollateralAmount existing trade collateral amount (collateral precision)
     * @param _existingLeverage existing trade leverage (1e3)
     * @param _newLeverage new trade leverage (1e3)
     */
    function _getNewCollateralAmount(uint256 _existingCollateralAmount, uint256 _existingLeverage, uint256 _newLeverage)
        internal
        pure
        returns (uint120)
    {
        return uint120((_existingCollateralAmount * _existingLeverage) / _newLeverage);
    }

    /**
     * @dev Fetches trade, does validation for update leverage request, and returns useful data
     * @param _input request input struct
     */
    function _validateRequest(IUpdateLeverageUtils.UpdateLeverageInput memory _input)
        internal
        view
        returns (ITradingStorage.Trade memory trade, bool isIncrease, uint256 collateralDelta)
    {
        trade = _getMultiCollatDiamond().getTrade(_input.user, _input.index);
        isIncrease = _input.newLeverage > trade.leverage;

        // 1. Check trade exists
        if (!trade.isOpen) revert IGeneralErrors.DoesntExist();

        // 2. Revert if any market order (market close, increase leverage, partial open, partial close) already exists for trade
        TradingCommonUtils.revertIfTradeHasPendingMarketOrder(_input.user, _input.index);

        // 3. Revert if collateral not active
        if (!_getMultiCollatDiamond().isCollateralActive(trade.collateralIndex)) {
            revert IGeneralErrors.InvalidCollateralIndex();
        }

        // 4. Validate leverage update
        if (
            _input.newLeverage == trade.leverage
                || (
                    isIncrease
                        ? _input.newLeverage > _getMultiCollatDiamond().pairMaxLeverage(trade.pairIndex) * 1e3
                        : _input.newLeverage < _getMultiCollatDiamond().pairMinLeverage(trade.pairIndex) * 1e3
                )
        ) revert ITradingInteractionsUtils.WrongLeverage();

        // 5. Check trade remaining collateral is enough to pay gov fee
        uint256 govFeeCollateral = TradingCommonUtils.getGovFeeCollateral(
            trade.user,
            trade.pairIndex,
            TradingCommonUtils.getMinPositionSizeCollateral(trade.collateralIndex, trade.pairIndex) / 2
        );
        uint256 newCollateralAmount =
            _getNewCollateralAmount(trade.collateralAmount, trade.leverage, _input.newLeverage);
        collateralDelta =
            isIncrease ? trade.collateralAmount - newCollateralAmount : newCollateralAmount - trade.collateralAmount;

        if (newCollateralAmount <= govFeeCollateral) revert ITradingInteractionsUtils.InsufficientCollateral();
    }

    /**
     * @dev Stores pending update leverage order and makes price aggregator request
     * @param _trade trade struct
     * @param _newLeverage new leverage (1e3)
     * @param _collateralDelta trade collateral delta (collateral precision)
     */
    function _initiateRequest(ITradingStorage.Trade memory _trade, uint24 _newLeverage, uint256 _collateralDelta)
        internal
        returns (ITradingStorage.Id memory orderId)
    {
        // 1. Store pending order
        ITradingStorage.Trade memory pendingOrderTrade;
        pendingOrderTrade.user = _trade.user;
        pendingOrderTrade.index = _trade.index;
        pendingOrderTrade.leverage = _newLeverage;
        pendingOrderTrade.collateralAmount = uint120(_collateralDelta);

        ITradingStorage.PendingOrder memory pendingOrder;
        pendingOrder.trade = pendingOrderTrade;
        pendingOrder.user = _trade.user;
        pendingOrder.orderType = ITradingStorage.PendingOrderType.UPDATE_LEVERAGE;

        pendingOrder = _getMultiCollatDiamond().storePendingOrder(pendingOrder);
        orderId = ITradingStorage.Id(pendingOrder.user, pendingOrder.index);

        // 2. Request price
        _getMultiCollatDiamond().getPrice(
            _trade.collateralIndex,
            _trade.pairIndex,
            orderId,
            pendingOrder.orderType,
            TradingCommonUtils.getMinPositionSizeCollateral(_trade.collateralIndex, _trade.pairIndex) / 2,
            0
        );
    }

    /**
     * @dev Calculates values for callback
     * @param _existingTrade existing trade struct
     * @param _pendingTrade pending trade struct
     * @param _isIncrease true if increase leverage, false if decrease leverage
     */
    function _prepareCallbackValues(
        ITradingStorage.Trade memory _existingTrade,
        ITradingStorage.Trade memory _pendingTrade,
        bool _isIncrease
    ) internal view returns (IUpdateLeverageUtils.UpdateLeverageValues memory values) {
        if (_existingTrade.isOpen == false) return values;

        values.newLeverage = _pendingTrade.leverage;
        values.govFeeCollateral = TradingCommonUtils.getGovFeeCollateral(
            _existingTrade.user,
            _existingTrade.pairIndex,
            TradingCommonUtils.getMinPositionSizeCollateral(_existingTrade.collateralIndex, _existingTrade.pairIndex)
                / 2 // use min fee / 2
        );
        values.newCollateralAmount = (
            _isIncrease
                ? _existingTrade.collateralAmount - _pendingTrade.collateralAmount
                : _existingTrade.collateralAmount + _pendingTrade.collateralAmount
        ) - values.govFeeCollateral;
        values.liqPrice = _getMultiCollatDiamond().getTradeLiquidationPrice(
            IBorrowingFees.LiqPriceInput(
                _existingTrade.collateralIndex,
                _existingTrade.user,
                _existingTrade.pairIndex,
                _existingTrade.index,
                _existingTrade.openPrice,
                _existingTrade.long,
                _isIncrease ? values.newCollateralAmount : _existingTrade.collateralAmount,
                _isIncrease ? values.newLeverage : _existingTrade.leverage,
                true
            )
        ); // for increase leverage we calculate new trade liquidation price and for decrease leverage we calculate existing trade liquidation price
    }

    /**
     * @dev Validates callback, and returns corresponding cancel reason
     * @param _existingTrade existing trade struct
     * @param _values pre-calculated useful values
     * @param _answer price aggregator answer
     */
    function _validateCallback(
        ITradingStorage.Trade memory _existingTrade,
        IUpdateLeverage.UpdateLeverageValues memory _values,
        ITradingCallbacks.AggregatorAnswer memory _answer
    ) internal view returns (ITradingCallbacks.CancelReason) {
        return !_existingTrade.isOpen
            ? ITradingCallbacks.CancelReason.NO_TRADE
            : _answer.price == 0
                ? ITradingCallbacks.CancelReason.MARKET_CLOSED
                : (_existingTrade.long ? _answer.price <= _values.liqPrice : _answer.price >= _values.liqPrice)
                    ? ITradingCallbacks.CancelReason.LIQ_REACHED
                    : _values.newLeverage > _getMultiCollatDiamond().pairMaxLeverage(_existingTrade.pairIndex) * 1e3
                        ? ITradingCallbacks.CancelReason.MAX_LEVERAGE
                        : ITradingCallbacks.CancelReason.NONE;
    }

    /**
     * @dev Handles trade update, removes gov fee OI, and transfers collateral delta (for both successful and failed requests)
     * @param _trade trade struct
     * @param _pendingTrade pending trade struct
     * @param _values pre-calculated useful values
     * @param _cancelReason cancel reason
     * @param _isIncrease true if increase leverage, false if decrease leverage
     */
    function _handleCallback(
        ITradingStorage.Trade memory _trade,
        ITradingStorage.Trade memory _pendingTrade,
        IUpdateLeverageUtils.UpdateLeverageValues memory _values,
        ITradingCallbacks.CancelReason _cancelReason,
        bool _isIncrease
    ) internal {
        // 1. Request successful
        if (_cancelReason == ITradingCallbacks.CancelReason.NONE) {
            // 1. Request successful
            // 1.1 Update trade collateral (- gov fee) and leverage, openPrice stays the same
            _getMultiCollatDiamond().updateTradePosition(
                ITradingStorage.Id(_trade.user, _trade.index),
                uint120(_values.newCollateralAmount),
                uint24(_values.newLeverage),
                _trade.openPrice
            );

            // 1.2 If leverage increase, transfer collateral delta to trader
            if (_isIncrease) {
                TradingCommonUtils.transferCollateralTo(
                    _trade.collateralIndex, _trade.user, _pendingTrade.collateralAmount
                );
            }
        } else {
            // 2. Request canceled
            // 2.1 Remove gov fee from trade collateral
            _getMultiCollatDiamond().updateTradeCollateralAmount(
                ITradingStorage.Id(_trade.user, _trade.index),
                _trade.collateralAmount - uint120(_values.govFeeCollateral)
            );
            // 2.2 If leverage decrease, send back collateral delta to trader
            if (!_isIncrease) {
                TradingCommonUtils.transferCollateralTo(
                    _trade.collateralIndex, _trade.user, _pendingTrade.collateralAmount
                );
            }
        }
    }
}
