// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "../interfaces/IGNSMultiCollatDiamond.sol";
import "../interfaces/IGToken.sol";
import "../interfaces/IGNSStaking.sol";
import "../interfaces/IERC20.sol";

import "./StorageUtils.sol";
import "./AddressStoreUtils.sol";
import "./TradingCommonUtils.sol";
import "./updateLeverage/UpdateLeverageLifecycles.sol";
import "./updatePositionSize/UpdatePositionSizeLifecycles.sol";

/**
 * @dev GNSTradingCallbacks facet internal library
 */
library TradingCallbacksUtils {
    /**
     * @dev Modifier to only allow trading action when trading is activated (= revert if not activated)
     */
    modifier tradingActivated() {
        if (_getMultiCollatDiamond().getTradingActivated() != ITradingStorage.TradingActivated.ACTIVATED) {
            revert IGeneralErrors.Paused();
        }
        _;
    }

    /**
     * @dev Modifier to only allow trading action when trading is activated or close only (= revert if paused)
     */
    modifier tradingActivatedOrCloseOnly() {
        if (_getMultiCollatDiamond().getTradingActivated() == ITradingStorage.TradingActivated.PAUSED) {
            revert IGeneralErrors.Paused();
        }
        _;
    }

    /**
     * @dev Check ITradingCallbacksUtils interface for documentation
     */
    function initializeCallbacks(uint8 _vaultClosingFeeP) internal {
        updateVaultClosingFeeP(_vaultClosingFeeP);
    }

    /**
     * @dev Check ITradingCallbacksUtils interface for documentation
     */
    function updateVaultClosingFeeP(uint8 _valueP) internal {
        if (_valueP > 100) revert IGeneralErrors.AboveMax();

        _getStorage().vaultClosingFeeP = _valueP;

        emit ITradingCallbacksUtils.VaultClosingFeePUpdated(_valueP);
    }

    /**
     * @dev Check ITradingCallbacksUtils interface for documentation
     */
    function claimPendingGovFees() internal {
        uint8 collateralsCount = _getMultiCollatDiamond().getCollateralsCount();
        for (uint8 i = 1; i <= collateralsCount; ++i) {
            uint256 feesAmountCollateral = _getStorage().pendingGovFees[i];

            if (feesAmountCollateral > 0) {
                _getStorage().pendingGovFees[i] = 0;

                TradingCommonUtils.transferCollateralTo(i, msg.sender, feesAmountCollateral);

                emit ITradingCallbacksUtils.PendingGovFeesClaimed(i, feesAmountCollateral);
            }
        }
    }

    /**
     * @dev Check ITradingCallbacksUtils interface for documentation
     */
    function openTradeMarketCallback(ITradingCallbacks.AggregatorAnswer memory _a) internal tradingActivated {
        ITradingStorage.PendingOrder memory o = _getPendingOrder(_a.orderId);

        if (!o.isOpen) return;

        ITradingStorage.Trade memory t = o.trade;

        (uint256 priceImpactP, uint256 priceAfterImpact, ITradingCallbacks.CancelReason cancelReason) =
            _openTradePrep(t, _a.price, _a.price, _a.spreadP, o.maxSlippageP);

        t.openPrice = uint64(priceAfterImpact);

        if (cancelReason == ITradingCallbacks.CancelReason.NONE) {
            t = _registerTrade(t, o);

            emit ITradingCallbacksUtils.MarketExecuted(
                _a.orderId, t, true, t.openPrice, priceImpactP, 0, 0, _getCollateralPriceUsd(t.collateralIndex)
            );
        } else {
            // Gov fee to pay for oracle cost
            TradingCommonUtils.updateFeeTierPoints(t.collateralIndex, t.user, t.pairIndex, 0);
            uint256 govFees = TradingCommonUtils.distributeGovFeeCollateral(
                t.collateralIndex,
                t.user,
                t.pairIndex,
                TradingCommonUtils.getMinPositionSizeCollateral(t.collateralIndex, t.pairIndex) / 2, // use min fee / 2
                0
            );
            TradingCommonUtils.transferCollateralTo(t.collateralIndex, t.user, t.collateralAmount - govFees);

            emit ITradingCallbacksUtils.MarketOpenCanceled(_a.orderId, t.user, t.pairIndex, cancelReason);
        }

        _getMultiCollatDiamond().closePendingOrder(_a.orderId);
    }

    /**
     * @dev Check ITradingCallbacksUtils interface for documentation
     */
    function closeTradeMarketCallback(ITradingCallbacks.AggregatorAnswer memory _a)
        internal
        tradingActivatedOrCloseOnly
    {
        ITradingStorage.PendingOrder memory o = _getPendingOrder(_a.orderId);

        if (!o.isOpen) return;

        ITradingStorage.Trade memory t = _getTrade(o.trade.user, o.trade.index);

        ITradingCallbacks.CancelReason cancelReason = !t.isOpen
            ? ITradingCallbacks.CancelReason.NO_TRADE
            : (_a.price == 0 ? ITradingCallbacks.CancelReason.MARKET_CLOSED : ITradingCallbacks.CancelReason.NONE);

        if (cancelReason != ITradingCallbacks.CancelReason.NO_TRADE) {
            ITradingCallbacks.Values memory v;

            if (cancelReason == ITradingCallbacks.CancelReason.NONE) {
                v.profitP = TradingCommonUtils.getPnlPercent(t.openPrice, _a.price, t.long, t.leverage);

                v.amountSentToTrader = _unregisterTrade(t, v.profitP, o.orderType);

                emit ITradingCallbacksUtils.MarketExecuted(
                    _a.orderId,
                    t,
                    false,
                    _a.price,
                    0,
                    v.profitP,
                    v.amountSentToTrader,
                    _getCollateralPriceUsd(t.collateralIndex)
                );
            } else {
                // Charge gov fee
                TradingCommonUtils.updateFeeTierPoints(t.collateralIndex, t.user, t.pairIndex, 0);
                uint256 govFee = TradingCommonUtils.distributeGovFeeCollateral(
                    t.collateralIndex,
                    t.user,
                    t.pairIndex,
                    TradingCommonUtils.getMinPositionSizeCollateral(t.collateralIndex, t.pairIndex) / 2, // use min fee / 2
                    0
                );

                // Deduct from trade collateral
                _getMultiCollatDiamond().updateTradeCollateralAmount(
                    ITradingStorage.Id({user: t.user, index: t.index}), t.collateralAmount - uint120(govFee)
                );
            }
        }

        if (cancelReason != ITradingCallbacks.CancelReason.NONE) {
            emit ITradingCallbacksUtils.MarketCloseCanceled(_a.orderId, t.user, t.pairIndex, t.index, cancelReason);
        }

        _getMultiCollatDiamond().closePendingOrder(_a.orderId);
    }

    function reverseTradeMarketCallback(ITradingCallbacks.AggregatorAnswer memory _a) internal tradingActivated {
        ITradingStorage.PendingOrder memory o = _getPendingOrder(_a.orderId);

        if (!o.isOpen) return;

        ITradingStorage.Trade memory t = _getTrade(o.trade.user, o.trade.index);

        ITradingCallbacks.CancelReason cancelReason = !t.isOpen
            ? ITradingCallbacks.CancelReason.NO_TRADE
            : (_a.price == 0 ? ITradingCallbacks.CancelReason.MARKET_CLOSED : ITradingCallbacks.CancelReason.NONE);

        ITradingCallbacks.Values memory v;
        if (cancelReason != ITradingCallbacks.CancelReason.NO_TRADE) {
            if (cancelReason == ITradingCallbacks.CancelReason.NONE) {
                v.profitP = TradingCommonUtils.getPnlPercent(t.openPrice, _a.price, t.long, t.leverage);

                v.amountSentToTrader = _unregisterTrade(t, v.profitP, o.orderType);

                emit ITradingCallbacksUtils.MarketExecuted(
                    _a.orderId,
                    t,
                    false,
                    _a.price,
                    0,
                    v.profitP,
                    v.amountSentToTrader,
                    _getCollateralPriceUsd(t.collateralIndex)
                );
            } else {
                // Charge gov fee
                TradingCommonUtils.updateFeeTierPoints(t.collateralIndex, t.user, t.pairIndex, 0);
                uint256 govFee = TradingCommonUtils.distributeGovFeeCollateral(
                    t.collateralIndex,
                    t.user,
                    t.pairIndex,
                    TradingCommonUtils.getMinPositionSizeCollateral(t.collateralIndex, t.pairIndex) / 2, // use min fee / 2
                    0
                );

                // Deduct from trade collateral
                _getMultiCollatDiamond().updateTradeCollateralAmount(
                    ITradingStorage.Id({user: t.user, index: t.index}), t.collateralAmount - uint120(govFee)
                );
            }
        }

        if (cancelReason != ITradingCallbacks.CancelReason.NONE) {
            emit ITradingCallbacksUtils.MarketCloseCanceled(_a.orderId, t.user, t.pairIndex, t.index, cancelReason);
        }

        _getMultiCollatDiamond().closePendingOrder(_a.orderId);

        t.collateralAmount = uint120(v.amountSentToTrader);
        (uint256 priceImpactP, uint256 priceAfterImpact, ITradingCallbacks.CancelReason cancelReasonOfOpen) =
            _openTradePrep(t, _a.price, _a.price, _a.spreadP, o.maxSlippageP);

        t.openPrice = uint64(priceAfterImpact);

        if (cancelReason == ITradingCallbacks.CancelReason.NONE) {
            t = _registerTrade(t, o);

            emit ITradingCallbacksUtils.MarketExecuted(
                _a.orderId, t, true, t.openPrice, priceImpactP, 0, 0, _getCollateralPriceUsd(t.collateralIndex)
            );
        } else {
            // Gov fee to pay for oracle cost
            TradingCommonUtils.updateFeeTierPoints(t.collateralIndex, t.user, t.pairIndex, 0);
            uint256 govFees = TradingCommonUtils.distributeGovFeeCollateral(
                t.collateralIndex,
                t.user,
                t.pairIndex,
                TradingCommonUtils.getMinPositionSizeCollateral(t.collateralIndex, t.pairIndex) / 2, // use min fee / 2
                0
            );
            TradingCommonUtils.transferCollateralTo(t.collateralIndex, t.user, t.collateralAmount - govFees);

            emit ITradingCallbacksUtils.MarketOpenCanceled(_a.orderId, t.user, t.pairIndex, cancelReason);
        }
    }

    /**
     * @dev Check ITradingCallbacksUtils interface for documentation
     */
    function executeTriggerOpenOrderCallback(ITradingCallbacks.AggregatorAnswer memory _a) internal tradingActivated {
        ITradingStorage.PendingOrder memory o = _getPendingOrder(_a.orderId);

        if (!o.isOpen) return;

        ITradingStorage.Trade memory t = _getTrade(o.trade.user, o.trade.index);

        ITradingCallbacks.CancelReason cancelReason =
            !t.isOpen ? ITradingCallbacks.CancelReason.NO_TRADE : ITradingCallbacks.CancelReason.NONE;

        if (cancelReason == ITradingCallbacks.CancelReason.NONE) {
            cancelReason = (_a.high >= t.openPrice && _a.low <= t.openPrice)
                ? ITradingCallbacks.CancelReason.NONE
                : ITradingCallbacks.CancelReason.NOT_HIT;

            (uint256 priceImpactP, uint256 priceAfterImpact, ITradingCallbacks.CancelReason _cancelReason) =
            _openTradePrep(
                t,
                cancelReason == ITradingCallbacks.CancelReason.NONE ? t.openPrice : _a.open,
                _a.open,
                _a.spreadP,
                _getMultiCollatDiamond().getTradeInfo(t.user, t.index).maxSlippageP
            );

            bool exactExecution = cancelReason == ITradingCallbacks.CancelReason.NONE;

            cancelReason = !exactExecution
                && (
                    t.tradeType == ITradingStorage.TradeType.STOP
                        ? (t.long ? _a.open < t.openPrice : _a.open > t.openPrice)
                        : (t.long ? _a.open > t.openPrice : _a.open < t.openPrice)
                ) ? ITradingCallbacks.CancelReason.NOT_HIT : _cancelReason;

            if (cancelReason == ITradingCallbacks.CancelReason.NONE) {
                // Unregister open order
                _getMultiCollatDiamond().closeTrade(ITradingStorage.Id({user: t.user, index: t.index}));

                // Store trade
                t.openPrice = uint64(priceAfterImpact);
                t.tradeType = ITradingStorage.TradeType.TRADE;
                t = _registerTrade(t, o);

                emit ITradingCallbacksUtils.LimitExecuted(
                    _a.orderId,
                    t,
                    o.user,
                    o.orderType,
                    t.openPrice,
                    priceImpactP,
                    0,
                    0,
                    _getCollateralPriceUsd(t.collateralIndex),
                    exactExecution
                );
            }
        }

        if (cancelReason != ITradingCallbacks.CancelReason.NONE) {
            emit ITradingCallbacksUtils.TriggerOrderCanceled(_a.orderId, o.user, o.orderType, cancelReason);
        }

        _getMultiCollatDiamond().closePendingOrder(_a.orderId);
    }

    /**
     * @dev Check ITradingCallbacksUtils interface for documentation
     */
    function executeTriggerCloseOrderCallback(ITradingCallbacks.AggregatorAnswer memory _a)
        internal
        tradingActivatedOrCloseOnly
    {
        ITradingStorage.PendingOrder memory o = _getPendingOrder(_a.orderId);

        if (!o.isOpen) return;

        ITradingStorage.Trade memory t = _getTrade(o.trade.user, o.trade.index);

        ITradingCallbacks.CancelReason cancelReason = _a.open == 0
            ? ITradingCallbacks.CancelReason.MARKET_CLOSED
            : (!t.isOpen ? ITradingCallbacks.CancelReason.NO_TRADE : ITradingCallbacks.CancelReason.NONE);

        if (cancelReason == ITradingCallbacks.CancelReason.NONE) {
            ITradingCallbacks.Values memory v;

            if (o.orderType == ITradingStorage.PendingOrderType.LIQ_CLOSE) {
                v.liqPrice = TradingCommonUtils.getTradeLiquidationPrice(t, true);
            }

            uint256 triggerPrice = o.orderType == ITradingStorage.PendingOrderType.TP_CLOSE
                ? t.tp
                : (o.orderType == ITradingStorage.PendingOrderType.SL_CLOSE ? t.sl : v.liqPrice);

            v.exactExecution = triggerPrice > 0 && _a.low <= triggerPrice && _a.high >= triggerPrice;
            v.executionPrice = v.exactExecution ? triggerPrice : _a.open;

            cancelReason = (
                v.exactExecution
                    || (
                        o.orderType == ITradingStorage.PendingOrderType.LIQ_CLOSE
                            && (t.long ? _a.open <= v.liqPrice : _a.open >= v.liqPrice)
                    )
                    || (
                        o.orderType == ITradingStorage.PendingOrderType.TP_CLOSE && t.tp > 0
                            && (t.long ? _a.open >= t.tp : _a.open <= t.tp)
                    )
                    || (
                        o.orderType == ITradingStorage.PendingOrderType.SL_CLOSE && t.sl > 0
                            && (t.long ? _a.open <= t.sl : _a.open >= t.sl)
                    )
            ) ? ITradingCallbacks.CancelReason.NONE : ITradingCallbacks.CancelReason.NOT_HIT;

            // If can be triggered
            if (cancelReason == ITradingCallbacks.CancelReason.NONE) {
                v.profitP = TradingCommonUtils.getPnlPercent(t.openPrice, uint64(v.executionPrice), t.long, t.leverage);

                v.amountSentToTrader = _unregisterTrade(t, v.profitP, o.orderType);

                emit ITradingCallbacksUtils.LimitExecuted(
                    _a.orderId,
                    t,
                    o.user,
                    o.orderType,
                    v.executionPrice,
                    0,
                    v.profitP,
                    v.amountSentToTrader,
                    _getCollateralPriceUsd(t.collateralIndex),
                    v.exactExecution
                );
            }
        }

        if (cancelReason != ITradingCallbacks.CancelReason.NONE) {
            emit ITradingCallbacksUtils.TriggerOrderCanceled(_a.orderId, o.user, o.orderType, cancelReason);
        }

        _getMultiCollatDiamond().closePendingOrder(_a.orderId);
    }

    /**
     * @dev Check ITradingCallbacksUtils interface for documentation
     */
    function updateLeverageCallback(ITradingCallbacks.AggregatorAnswer memory _a) internal tradingActivated {
        ITradingStorage.PendingOrder memory order = _getMultiCollatDiamond().getPendingOrder(_a.orderId);

        if (!order.isOpen) return;

        UpdateLeverageLifecycles.executeUpdateLeverage(order, _a);
    }

    /**
     * @dev Check ITradingCallbacksUtils interface for documentation
     */
    function increasePositionSizeMarketCallback(ITradingCallbacks.AggregatorAnswer memory _a)
        internal
        tradingActivated
    {
        ITradingStorage.PendingOrder memory order = _getMultiCollatDiamond().getPendingOrder(_a.orderId);

        if (!order.isOpen) return;

        UpdatePositionSizeLifecycles.executeIncreasePositionSizeMarket(order, _a);
    }

    /**
     * @dev Check ITradingCallbacksUtils interface for documentation
     */
    function decreasePositionSizeMarketCallback(ITradingCallbacks.AggregatorAnswer memory _a)
        internal
        tradingActivatedOrCloseOnly
    {
        ITradingStorage.PendingOrder memory order = _getMultiCollatDiamond().getPendingOrder(_a.orderId);

        if (!order.isOpen) return;

        UpdatePositionSizeLifecycles.executeDecreasePositionSizeMarket(order, _a);
    }

    /**
     * @dev Check ITradingCallbacksUtils interface for documentation
     */
    function getVaultClosingFeeP() internal view returns (uint8) {
        return _getStorage().vaultClosingFeeP;
    }

    /**
     * @dev Check ITradingCallbacksUtils interface for documentation
     */
    function getPendingGovFeesCollateral(uint8 _collateralIndex) internal view returns (uint256) {
        return _getStorage().pendingGovFees[_collateralIndex];
    }

    /**
     * @dev Returns storage slot to use when fetching storage relevant to library
     */
    function _getSlot() internal pure returns (uint256) {
        return StorageUtils.GLOBAL_TRADING_CALLBACKS_SLOT;
    }

    /**
     * @dev Returns storage pointer for storage struct in diamond contract, at defined slot
     */
    function _getStorage() internal pure returns (ITradingCallbacks.TradingCallbacksStorage storage s) {
        uint256 storageSlot = _getSlot();
        assembly {
            s.slot := storageSlot
        }
    }

    /**
     * @dev Returns current address as multi-collateral diamond interface to call other facets functions.
     */
    function _getMultiCollatDiamond() internal view returns (IGNSMultiCollatDiamond) {
        return IGNSMultiCollatDiamond(address(this));
    }

    /**
     * @dev Registers a trade in storage, and handles all fees and rewards
     * @param _trade Trade to register
     * @param _pendingOrder Corresponding pending order
     * @return Final registered trade
     */
    function _registerTrade(ITradingStorage.Trade memory _trade, ITradingStorage.PendingOrder memory _pendingOrder)
        internal
        returns (ITradingStorage.Trade memory)
    {
        // 1. Deduct gov fee, GNS staking fee (previously dev fee), Market/Limit fee
        _trade.collateralAmount -= TradingCommonUtils.processOpeningFees(
            _trade,
            TradingCommonUtils.getPositionSizeCollateral(_trade.collateralAmount, _trade.leverage),
            _pendingOrder.orderType
        );

        // 2. Store final trade in storage contract
        ITradingStorage.TradeInfo memory tradeInfo;
        _trade = _getMultiCollatDiamond().storeTrade(_trade, tradeInfo);

        return _trade;
    }

    /**
     * @dev Unregisters a trade from storage, and handles all fees and rewards
     * @param _trade Trade to unregister
     * @param _profitP Profit percentage (1e10)
     * @param _orderType pending order type
     * @return tradeValueCollateral Amount of collateral sent to trader, collateral + pnl (collateral precision)
     */
    function _unregisterTrade(
        ITradingStorage.Trade memory _trade,
        int256 _profitP,
        ITradingStorage.PendingOrderType _orderType
    ) internal returns (uint256 tradeValueCollateral) {
        // 1. Process closing fees, fill 'v' with closing/trigger fees and collateral left in storage, to avoid stack too deep
        ITradingCallbacks.Values memory v = TradingCommonUtils.processClosingFees(
            _trade, TradingCommonUtils.getPositionSizeCollateral(_trade.collateralAmount, _trade.leverage), _orderType
        );

        // 2. Calculate borrowing fee and net trade value (with pnl and after all closing/holding fees)
        uint256 borrowingFeeCollateral;
        (tradeValueCollateral, borrowingFeeCollateral) = TradingCommonUtils.getTradeValueCollateral(
            _trade,
            _profitP,
            v.closingFeeCollateral + v.triggerFeeCollateral,
            _getMultiCollatDiamond().getCollateral(_trade.collateralIndex).precisionDelta,
            _orderType
        );

        // 3. Take collateral from vault if winning trade or send collateral to vault if losing trade
        TradingCommonUtils.handleTradePnl(
            _trade, int256(tradeValueCollateral), int256(v.collateralLeftInStorage), borrowingFeeCollateral
        );

        // 4. Unregister trade from storage
        _getMultiCollatDiamond().closeTrade(ITradingStorage.Id({user: _trade.user, index: _trade.index}));
    }

    /**
     * @dev Makes pre-trade checks: price impact, if trade should be cancelled based on parameters like: PnL, leverage, slippage, etc.
     * @param _trade trade input
     * @param _executionPrice execution price (1e10 precision)
     * @param _marketPrice market price (1e10 precision)
     * @param _spreadP spread % (1e10 precision)
     * @param _maxSlippageP max slippage % (1e3 precision)
     */
    function _openTradePrep(
        ITradingStorage.Trade memory _trade,
        uint256 _executionPrice,
        uint256 _marketPrice,
        uint256 _spreadP,
        uint256 _maxSlippageP
    )
        internal
        view
        returns (uint256 priceImpactP, uint256 priceAfterImpact, ITradingCallbacks.CancelReason cancelReason)
    {
        uint256 positionSizeCollateral =
            TradingCommonUtils.getPositionSizeCollateral(_trade.collateralAmount, _trade.leverage);

        (priceImpactP, priceAfterImpact) = _getMultiCollatDiamond().getTradePriceImpact(
            TradingCommonUtils.getMarketExecutionPrice(_executionPrice, _spreadP, _trade.long),
            _trade.pairIndex,
            _trade.long,
            _getMultiCollatDiamond().getUsdNormalizedValue(_trade.collateralIndex, positionSizeCollateral)
        );

        uint256 maxSlippage = (uint256(_trade.openPrice) * _maxSlippageP) / 100 / 1e3;

        cancelReason = _marketPrice == 0
            ? ITradingCallbacks.CancelReason.MARKET_CLOSED
            : (
                (
                    _trade.long
                        ? priceAfterImpact > _trade.openPrice + maxSlippage
                        : priceAfterImpact < _trade.openPrice - maxSlippage
                )
                    ? ITradingCallbacks.CancelReason.SLIPPAGE
                    : (_trade.tp > 0 && (_trade.long ? priceAfterImpact >= _trade.tp : priceAfterImpact <= _trade.tp))
                        ? ITradingCallbacks.CancelReason.TP_REACHED
                        : (_trade.sl > 0 && (_trade.long ? _executionPrice <= _trade.sl : _executionPrice >= _trade.sl))
                            ? ITradingCallbacks.CancelReason.SL_REACHED
                            : !TradingCommonUtils.isWithinExposureLimits(
                                _trade.collateralIndex, _trade.pairIndex, _trade.long, positionSizeCollateral
                            )
                                ? ITradingCallbacks.CancelReason.EXPOSURE_LIMITS
                                : (priceImpactP * _trade.leverage) / 1e3 > ConstantsUtils.MAX_OPEN_NEGATIVE_PNL_P
                                    ? ITradingCallbacks.CancelReason.PRICE_IMPACT
                                    : _trade.leverage > _getMultiCollatDiamond().pairMaxLeverage(_trade.pairIndex) * 1e3
                                        ? ITradingCallbacks.CancelReason.MAX_LEVERAGE
                                        : ITradingCallbacks.CancelReason.NONE
            );
    }

    /**
     * @dev Returns pending order from storage
     * @param _orderId Order ID
     * @return Pending order
     */
    function _getPendingOrder(ITradingStorage.Id memory _orderId)
        internal
        view
        returns (ITradingStorage.PendingOrder memory)
    {
        return _getMultiCollatDiamond().getPendingOrder(_orderId);
    }

    /**
     * @dev Returns collateral price in USD
     * @param _collateralIndex Collateral index
     * @return Collateral price in USD
     */
    function _getCollateralPriceUsd(uint8 _collateralIndex) internal view returns (uint256) {
        return _getMultiCollatDiamond().getCollateralPriceUsd(_collateralIndex);
    }

    /**
     * @dev Returns trade from storage
     * @param _trader Trader address
     * @param _index Trade index
     * @return Trade
     */
    function _getTrade(address _trader, uint32 _index) internal view returns (ITradingStorage.Trade memory) {
        return _getMultiCollatDiamond().getTrade(_trader, _index);
    }
}
