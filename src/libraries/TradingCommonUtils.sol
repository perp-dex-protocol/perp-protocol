// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../interfaces/IGToken.sol";
import "../interfaces/IGNSMultiCollatDiamond.sol";
import "../interfaces/IGNSStaking.sol";
import "../interfaces/IERC20.sol";

import "./ConstantsUtils.sol";
import "./AddressStoreUtils.sol";
import "./TradingCallbacksUtils.sol";

/**
 * @dev External library for helper functions commonly used in many places
 */
library TradingCommonUtils {
    using SafeERC20 for IERC20;

    // Pure functions

    /**
     * @dev Returns the current percent profit of a trade (1e10 precision)
     * @param _openPrice trade open price (1e10 precision)
     * @param _currentPrice trade current price (1e10 precision)
     * @param _long true for long, false for short
     * @param _leverage trade leverage (1e3 precision)
     */
    function getPnlPercent(uint64 _openPrice, uint64 _currentPrice, bool _long, uint24 _leverage)
        public
        pure
        returns (int256 p)
    {
        int256 pricePrecision = int256(ConstantsUtils.P_10);
        int256 maxPnlP = int256(ConstantsUtils.MAX_PNL_P) * pricePrecision;
        int256 minPnlP = -100 * int256(ConstantsUtils.P_10);

        int256 openPrice = int256(uint256(_openPrice));
        int256 currentPrice = int256(uint256(_currentPrice));
        int256 leverage = int256(uint256(_leverage));

        p = _openPrice > 0
            ? ((_long ? currentPrice - openPrice : openPrice - currentPrice) * 100 * pricePrecision * leverage) / openPrice
                / 1e3
            : int256(0);

        p = p > maxPnlP ? maxPnlP : p < minPnlP ? minPnlP : p;
    }

    /**
     * @dev Returns position size of trade in collateral tokens (avoids overflow from uint120 collateralAmount)
     * @param _collateralAmount collateral of trade
     * @param _leverage leverage of trade (1e3)
     */
    function getPositionSizeCollateral(uint120 _collateralAmount, uint24 _leverage) public pure returns (uint256) {
        return (uint256(_collateralAmount) * _leverage) / 1e3;
    }

    /**
     * @dev Calculates market execution price for a trade (1e10 precision)
     * @param _price price of the asset (1e10)
     * @param _spreadP spread percentage (1e10)
     * @param _long true if long, false if short
     */
    function getMarketExecutionPrice(uint256 _price, uint256 _spreadP, bool _long) external pure returns (uint256) {
        uint256 priceDiff = (_price * _spreadP) / 100 / ConstantsUtils.P_10;
        return _long ? _price + priceDiff : _price - priceDiff;
    }

    /**
     * @dev Converts collateral value to USD (1e18 precision)
     * @param _collateralAmount amount of collateral (collateral precision)
     * @param _collateralPrecisionDelta precision delta of collateral (10^18/10^decimals)
     * @param _collateralPriceUsd price of collateral in USD (1e8)
     */
    function convertCollateralToUsd(
        uint256 _collateralAmount,
        uint128 _collateralPrecisionDelta,
        uint256 _collateralPriceUsd
    ) public pure returns (uint256) {
        return (_collateralAmount * _collateralPrecisionDelta * _collateralPriceUsd) / 1e8;
    }

    /**
     * @dev Converts collateral value to GNS (1e18 precision)
     * @param _collateralAmount amount of collateral (collateral precision)
     * @param _collateralPrecisionDelta precision delta of collateral (10^18/10^decimals)
     * @param _gnsPriceCollateral price of GNS in collateral (1e10)
     */
    function convertCollateralToGns(
        uint256 _collateralAmount,
        uint128 _collateralPrecisionDelta,
        uint256 _gnsPriceCollateral
    ) public pure returns (uint256) {
        return ((_collateralAmount * _collateralPrecisionDelta * ConstantsUtils.P_10) / _gnsPriceCollateral);
    }

    /**
     * @dev Calculates trade value (useful when closing a trade)
     * @param _collateral amount of collateral (collateral precision)
     * @param _percentProfit profit percentage (1e10)
     * @param _borrowingFeeCollateral borrowing fee in collateral tokens (collateral precision)
     * @param _closingFeeCollateral closing fee in collateral tokens (collateral precision)
     * @param _collateralPrecisionDelta precision delta of collateral (10^18/10^decimals)
     * @param _orderType corresponding pending order type
     */
    function getTradeValuePure(
        uint256 _collateral,
        int256 _percentProfit,
        uint256 _borrowingFeeCollateral,
        uint256 _closingFeeCollateral,
        uint128 _collateralPrecisionDelta,
        ITradingStorage.PendingOrderType _orderType
    ) public pure returns (uint256) {
        if (_orderType == ITradingStorage.PendingOrderType.LIQ_CLOSE) return 0;

        int256 precisionDelta = int256(uint256(_collateralPrecisionDelta));

        // Multiply collateral by precisionDelta so we don't lose precision for low decimals
        int256 value = (
            int256(_collateral) * precisionDelta
                + (int256(_collateral) * precisionDelta * _percentProfit) / int256(ConstantsUtils.P_10) / 100
        ) / precisionDelta - int256(_borrowingFeeCollateral) - int256(_closingFeeCollateral);

        int256 collateralLiqThreshold = (int256(_collateral) * int256(100 - ConstantsUtils.LIQ_THRESHOLD_P)) / 100;

        return value > collateralLiqThreshold ? uint256(value) : 0;
    }

    // View functions

    /**
     * @dev Returns position size of trade in collateral tokens (avoids overflow from uint120 collateralAmount)
     * @param _collateralIndex collateral index
     * @param _pairIndex pair index
     */
    function getMinPositionSizeCollateral(uint8 _collateralIndex, uint256 _pairIndex) public view returns (uint256) {
        return _getMultiCollatDiamond().getCollateralFromUsdNormalizedValue(
            _collateralIndex, _getMultiCollatDiamond().pairMinPositionSizeUsd(_pairIndex)
        );
    }

    /**
     * @dev Returns position size to use when charging fees
     * @param _collateralIndex collateral index
     * @param _pairIndex pair index
     * @param _positionSizeCollateral trade position size in collateral tokens (collateral precision)
     */
    function getPositionSizeCollateralBasis(uint8 _collateralIndex, uint256 _pairIndex, uint256 _positionSizeCollateral)
        public
        view
        returns (uint256)
    {
        uint256 minPositionSizeCollateral = getMinPositionSizeCollateral(_collateralIndex, _pairIndex);
        return _positionSizeCollateral > minPositionSizeCollateral ? _positionSizeCollateral : minPositionSizeCollateral;
    }

    /**
     * @dev Checks if total position size is not higher than maximum allowed open interest for a pair
     * @param _collateralIndex index of collateral
     * @param _pairIndex index of pair
     * @param _long true if long, false if short
     * @param _positionSizeCollateralDelta position size delta in collateral tokens (collateral precision)
     */
    function isWithinExposureLimits(
        uint8 _collateralIndex,
        uint16 _pairIndex,
        bool _long,
        uint256 _positionSizeCollateralDelta
    ) external view returns (bool) {
        return _getMultiCollatDiamond().getPairOiCollateral(_collateralIndex, _pairIndex, _long)
            + _positionSizeCollateralDelta <= _getMultiCollatDiamond().getPairMaxOiCollateral(_collateralIndex, _pairIndex)
            && _getMultiCollatDiamond().withinMaxBorrowingGroupOi(
                _collateralIndex, _pairIndex, _long, _positionSizeCollateralDelta
            );
    }

    /**
     * @dev Convenient wrapper to return trade borrowing fee in collateral tokens (collateral precision)
     * @param _trade trade input
     */
    function getTradeBorrowingFeeCollateral(ITradingStorage.Trade memory _trade) public view returns (uint256) {
        return _getMultiCollatDiamond().getTradeBorrowingFee(
            IBorrowingFees.BorrowingFeeInput(
                _trade.collateralIndex,
                _trade.user,
                _trade.pairIndex,
                _trade.index,
                _trade.long,
                _trade.collateralAmount,
                _trade.leverage
            )
        );
    }

    /**
     * @dev Convenient wrapper to return trade liquidation price (1e10)
     * @param _trade trade input
     */
    function getTradeLiquidationPrice(ITradingStorage.Trade memory _trade, bool _useBorrowingFees)
        public
        view
        returns (uint256)
    {
        return _getMultiCollatDiamond().getTradeLiquidationPrice(
            IBorrowingFees.LiqPriceInput(
                _trade.collateralIndex,
                _trade.user,
                _trade.pairIndex,
                _trade.index,
                _trade.openPrice,
                _trade.long,
                _trade.collateralAmount,
                _trade.leverage,
                _useBorrowingFees
            )
        );
    }

    /**
     * @dev Returns trade value and borrowing fee in collateral tokens
     * @param _trade trade data
     * @param _percentProfit profit percentage (1e10)
     * @param _closingFeesCollateral closing fees in collateral tokens (collateral precision)
     * @param _collateralPrecisionDelta precision delta of collateral (10^18/10^decimals)
     * @param _orderType corresponding pending order type
     */
    function getTradeValueCollateral(
        ITradingStorage.Trade memory _trade,
        int256 _percentProfit,
        uint256 _closingFeesCollateral,
        uint128 _collateralPrecisionDelta,
        ITradingStorage.PendingOrderType _orderType
    ) external view returns (uint256 valueCollateral, uint256 borrowingFeesCollateral) {
        borrowingFeesCollateral = getTradeBorrowingFeeCollateral(_trade);

        valueCollateral = getTradeValuePure(
            _trade.collateralAmount,
            _percentProfit,
            borrowingFeesCollateral,
            _closingFeesCollateral,
            _collateralPrecisionDelta,
            _orderType
        );
    }

    /**
     * @dev Returns gov fee amount in collateral tokens
     * @param _trader address of trader
     * @param _pairIndex index of pair
     * @param _positionSizeCollateral position size in collateral tokens (collateral precision)
     */
    function getGovFeeCollateral(address _trader, uint32 _pairIndex, uint256 _positionSizeCollateral)
        public
        view
        returns (uint256)
    {
        return _getMultiCollatDiamond().calculateFeeAmount(
            _trader,
            (_positionSizeCollateral * _getMultiCollatDiamond().pairOpenFeeP(_pairIndex)) / ConstantsUtils.P_10 / 100
        );
    }

    /**
     * @dev Returns vault and gns staking fees in collateral tokens
     * @param _closingFeeCollateral closing fee in collateral tokens (collateral precision)
     * @param _triggerFeeCollateral trigger fee in collateral tokens (collateral precision)
     * @param _orderType corresponding order type
     */
    function getClosingFeesCollateral(
        uint256 _closingFeeCollateral,
        uint256 _triggerFeeCollateral,
        ITradingStorage.PendingOrderType _orderType
    ) public view returns (uint256 vaultClosingFeeCollateral, uint256 gnsStakingFeeCollateral) {
        uint256 vaultClosingFeeP = uint256(TradingCallbacksUtils._getStorage().vaultClosingFeeP);
        vaultClosingFeeCollateral = (_closingFeeCollateral * vaultClosingFeeP) / 100;

        gnsStakingFeeCollateral = (
            ConstantsUtils.isOrderTypeMarket(_orderType) ? _triggerFeeCollateral : (_triggerFeeCollateral * 8) / 10
        ) + (_closingFeeCollateral * (100 - vaultClosingFeeP)) / 100;
    }

    /**
     * @dev Reverts if user initiated any kind of pending market order on his trade
     * @param _user trade user
     * @param _index trade index
     */
    function revertIfTradeHasPendingMarketOrder(address _user, uint32 _index) public view {
        ITradingStorage.PendingOrderType[5] memory pendingOrderTypes = ConstantsUtils.getMarketOrderTypes();
        ITradingStorage.Id memory tradeId = ITradingStorage.Id(_user, _index);

        for (uint256 i; i < pendingOrderTypes.length; ++i) {
            ITradingStorage.PendingOrderType orderType = pendingOrderTypes[i];

            if (_getMultiCollatDiamond().getTradePendingOrderBlock(tradeId, orderType) > 0) {
                revert ITradingInteractionsUtils.ConflictingPendingOrder(orderType);
            }
        }
    }

    /**
     * @dev Returns gToken contract for a collateral index
     * @param _collateralIndex collateral index
     */
    function getGToken(uint8 _collateralIndex) public view returns (IGToken) {
        return IGToken(_getMultiCollatDiamond().getGToken(_collateralIndex));
    }

    // Transfers

    /**
     * @dev Transfers collateral from trader
     * @param _collateralIndex index of the collateral
     * @param _from sending address
     * @param _amountCollateral amount of collateral to receive (collateral precision)
     */
    function transferCollateralFrom(uint8 _collateralIndex, address _from, uint256 _amountCollateral) public {
        if (_amountCollateral > 0) {
            IERC20(_getMultiCollatDiamond().getCollateral(_collateralIndex).collateral).safeTransferFrom(
                _from, address(this), _amountCollateral
            );
        }
    }

    /**
     * @dev Transfers collateral to trader
     * @param _collateralIndex index of the collateral
     * @param _to receiving address
     * @param _amountCollateral amount of collateral to transfer (collateral precision)
     */
    function transferCollateralTo(uint8 _collateralIndex, address _to, uint256 _amountCollateral) public {
        if (_amountCollateral > 0) {
            IERC20(_getMultiCollatDiamond().getCollateral(_collateralIndex).collateral).safeTransfer(
                _to, _amountCollateral
            );
        }
    }

    /**
     * @dev Transfers GNS to address
     * @param _to receiving address
     * @param _amountGns amount of GNS to transfer (1e18)
     */
    function transferGnsTo(address _to, uint256 _amountGns) internal {
        if (_amountGns > 0) {
            IERC20(AddressStoreUtils.getAddresses().gns).safeTransfer(_to, _amountGns);
        }
    }

    /**
     * @dev Transfers GNS from address
     * @param _from sending address
     * @param _amountGns amount of GNS to receive (1e18)
     */
    function transferGnsFrom(address _from, uint256 _amountGns) internal {
        if (_amountGns > 0) {
            IERC20(AddressStoreUtils.getAddresses().gns).safeTransferFrom(_from, address(this), _amountGns);
        }
    }

    /**
     * @dev Sends collateral to gToken vault for negative pnl
     * @param _collateralIndex collateral index
     * @param _amountCollateral amount of collateral to send to vault (collateral precision)
     * @param _trader trader address
     */
    function sendCollateralToVault(uint8 _collateralIndex, uint256 _amountCollateral, address _trader) public {
        getGToken(_collateralIndex).receiveAssets(_amountCollateral, _trader);
    }

    /**
     * @dev Handles pnl transfers when (fully or partially) closing a trade
     * @param _trade trade struct
     * @param _collateralSentToTrader total amount to send to trader (collateral precision)
     * @param _availableCollateralInDiamond part of _collateralSentToTrader available in diamond balance (collateral precision)
     */
    function handleTradePnl(
        ITradingStorage.Trade memory _trade,
        int256 _collateralSentToTrader,
        int256 _availableCollateralInDiamond,
        uint256 _borrowingFeeCollateral
    ) external returns (uint256 traderDebt) {
        if (_collateralSentToTrader > _availableCollateralInDiamond) {
            getGToken(_trade.collateralIndex).sendAssets(
                uint256(_collateralSentToTrader - _availableCollateralInDiamond), _trade.user
            );
            if (_availableCollateralInDiamond >= 0) {
                transferCollateralTo(_trade.collateralIndex, _trade.user, uint256(_availableCollateralInDiamond));
            } else {
                traderDebt = uint256(-_availableCollateralInDiamond);
            }
        } else {
            getGToken(_trade.collateralIndex).receiveAssets(
                uint256(_availableCollateralInDiamond - _collateralSentToTrader), _trade.user
            );
            if (_collateralSentToTrader >= 0) {
                transferCollateralTo(_trade.collateralIndex, _trade.user, uint256(_collateralSentToTrader));
            } else {
                traderDebt = uint256(-_collateralSentToTrader);
            }
        }

        emit ITradingCallbacksUtils.BorrowingFeeCharged(_trade.user, _trade.collateralIndex, _borrowingFeeCollateral);
    }

    // Fees

    /**
     * @dev Updates a trader's fee tiers points based on his trade size
     * @param _collateralIndex collateral index
     * @param _trader address of trader
     * @param _positionSizeCollateral position size in collateral tokens (collateral precision)
     * @param _pairIndex index of pair
     */
    function updateFeeTierPoints(
        uint8 _collateralIndex,
        address _trader,
        uint256 _pairIndex,
        uint256 _positionSizeCollateral
    ) public {
        uint256 usdNormalizedPositionSize =
            _getMultiCollatDiamond().getUsdNormalizedValue(_collateralIndex, _positionSizeCollateral);
        _getMultiCollatDiamond().updateTraderPoints(_trader, usdNormalizedPositionSize, _pairIndex);
    }

    /**
     * @dev Distributes fee to gToken vault
     * @param _collateralIndex index of collateral
     * @param _trader address of trader
     * @param _valueCollateral fee in collateral tokens (collateral precision)
     */
    function distributeVaultFeeCollateral(uint8 _collateralIndex, address _trader, uint256 _valueCollateral) public {
        getGToken(_collateralIndex).distributeReward(_valueCollateral);
        emit ITradingCommonUtils.GTokenFeeCharged(_trader, _collateralIndex, _valueCollateral);
    }

    /**
     * @dev Calculates gov fee amount, charges it, and returns the amount charged (collateral precision)
     * @param _collateralIndex index of collateral
     * @param _trader address of trader
     * @param _pairIndex index of pair
     * @param _positionSizeCollateral position size in collateral tokens (collateral precision)
     * @param _referralFeesCollateral referral fees in collateral tokens (collateral precision)
     */
    function distributeGovFeeCollateral(
        uint8 _collateralIndex,
        address _trader,
        uint32 _pairIndex,
        uint256 _positionSizeCollateral,
        uint256 _referralFeesCollateral
    ) public returns (uint256 govFeeCollateral) {
        govFeeCollateral = getGovFeeCollateral(_trader, _pairIndex, _positionSizeCollateral) - _referralFeesCollateral;
        distributeExactGovFeeCollateral(_collateralIndex, _trader, govFeeCollateral);
    }

    /**
     * @dev Distributes gov fees exact amount
     * @param _collateralIndex index of collateral
     * @param _trader address of trader
     * @param _govFeeCollateral position size in collateral tokens (collateral precision)
     */
    function distributeExactGovFeeCollateral(uint8 _collateralIndex, address _trader, uint256 _govFeeCollateral)
        public
    {
        TradingCallbacksUtils._getStorage().pendingGovFees[_collateralIndex] += _govFeeCollateral;
        emit ITradingCommonUtils.GovFeeCharged(_trader, _collateralIndex, _govFeeCollateral);
    }

    /**
     * @dev Distributes GNS staking fee
     * @param _collateralIndex collateral index
     * @param _trader trader address
     * @param _amountCollateral amount of collateral tokens to distribute (collateral precision)
     */
    function distributeGnsStakingFeeCollateral(uint8 _collateralIndex, address _trader, uint256 _amountCollateral)
        public
    {
        IGNSStaking(AddressStoreUtils.getAddresses().gnsStaking).distributeReward(
            _getMultiCollatDiamond().getCollateral(_collateralIndex).collateral, _amountCollateral
        );
        emit ITradingCommonUtils.GnsStakingFeeCharged(_trader, _collateralIndex, _amountCollateral);
    }

    /**
     * @dev Distributes trigger fee in GNS tokens
     * @param _trader address of trader
     * @param _collateralIndex index of collateral
     * @param _triggerFeeCollateral trigger fee in collateral tokens (collateral precision)
     * @param _gnsPriceCollateral gns/collateral price (1e10 precision)
     * @param _collateralPrecisionDelta collateral precision delta (10^18/10^decimals)
     */
    function distributeTriggerFeeGns(
        address _trader,
        uint8 _collateralIndex,
        uint256 _triggerFeeCollateral,
        uint256 _gnsPriceCollateral,
        uint128 _collateralPrecisionDelta
    ) public {
        uint256 triggerFeeGns =
            convertCollateralToGns(_triggerFeeCollateral, _collateralPrecisionDelta, _gnsPriceCollateral);
        _getMultiCollatDiamond().distributeTriggerReward(triggerFeeGns);

        emit ITradingCommonUtils.TriggerFeeCharged(_trader, _collateralIndex, _triggerFeeCollateral);
    }

    /**
     * @dev Distributes opening fees for trade and returns the total fees charged in collateral tokens
     * @param _trade trade struct
     * @param _positionSizeCollateral position size in collateral tokens (collateral precision)
     * @param _orderType trade order type
     */
    function processOpeningFees(
        ITradingStorage.Trade memory _trade,
        uint256 _positionSizeCollateral,
        ITradingStorage.PendingOrderType _orderType
    ) external returns (uint120 totalFeesCollateral) {
        ITradingCallbacks.Values memory v;
        v.collateralPrecisionDelta = _getMultiCollatDiamond().getCollateral(_trade.collateralIndex).precisionDelta;

        // v.gnsPriceCollateral = _getMultiCollatDiamond().getGnsPriceCollateralIndex(_trade.collateralIndex);
        v.positionSizeCollateral =
            getPositionSizeCollateralBasis(_trade.collateralIndex, _trade.pairIndex, _positionSizeCollateral); // Charge fees on max(min position size, trade position size)

        // 1. Before charging any fee, re-calculate current trader fee tier cache
        updateFeeTierPoints(_trade.collateralIndex, _trade.user, _trade.pairIndex, _positionSizeCollateral);

        // 2. Charge referral fee (if applicable) and send collateral amount to vault
        if (_getMultiCollatDiamond().getTraderActiveReferrer(_trade.user) != address(0)) {
            v.reward1 = distributeReferralFeeCollateral(
                _trade.collateralIndex,
                _trade.user,
                _getMultiCollatDiamond().calculateFeeAmount(_trade.user, v.positionSizeCollateral), // apply fee tiers here to v.positionSizeCollateral itself to make correct calculations inside referrals
                _getMultiCollatDiamond().pairOpenFeeP(_trade.pairIndex),
                v.gnsPriceCollateral
            );

            sendCollateralToVault(_trade.collateralIndex, v.reward1, _trade.user);
            totalFeesCollateral += uint120(v.reward1);

            emit ITradingCommonUtils.ReferralFeeCharged(_trade.user, _trade.collateralIndex, v.reward1);
        }

        // 3. Calculate gov fee (- referral fee if applicable)
        uint256 govFeeCollateral = distributeGovFeeCollateral(
            _trade.collateralIndex,
            _trade.user,
            _trade.pairIndex,
            v.positionSizeCollateral,
            v.reward1 / 2 // half of referral fee taken from gov fee, other half from GNS staking fee
        );

        // 4. Calculate Market/Limit fee
        v.reward2 = _getMultiCollatDiamond().calculateFeeAmount(
            _trade.user,
            (v.positionSizeCollateral * _getMultiCollatDiamond().pairTriggerOrderFeeP(_trade.pairIndex)) / 100
                / ConstantsUtils.P_10
        );

        // 5. Deduct gov fee, GNS staking fee (previously dev fee), Market/Limit fee
        totalFeesCollateral += 2 * uint120(govFeeCollateral) + uint120(v.reward2);

        // 6. Distribute Oracle fee and send collateral amount to vault if applicable
        // if (!ConstantsUtils.isOrderTypeMarket(_orderType)) {
        //     v.reward3 = (v.reward2 * 2) / 10; // 20% of limit fees
        //     sendCollateralToVault(_trade.collateralIndex, v.reward3, _trade.user);

        //     distributeTriggerFeeGns(
        //         _trade.user, _trade.collateralIndex, v.reward3, v.gnsPriceCollateral, v.collateralPrecisionDelta
        //     );
        // }

        // 7. Distribute GNS staking fee (previous dev fee + market/limit fee - oracle reward)
        // distributeGnsStakingFeeCollateral(_trade.collateralIndex, _trade.user, govFeeCollateral + v.reward2 - v.reward3);
    }

    /**
     * @dev Distributes closing fees for trade (not used for partials, only full closes)
     * @param _trade trade struct
     * @param _positionSizeCollateral position size in collateral tokens (collateral precision)
     * @param _orderType trade order type
     */
    function processClosingFees(
        ITradingStorage.Trade memory _trade,
        uint256 _positionSizeCollateral,
        ITradingStorage.PendingOrderType _orderType
    ) external returns (ITradingCallbacks.Values memory values) {
        // 1. Calculate closing fees
        values.positionSizeCollateral =
            getPositionSizeCollateralBasis(_trade.collateralIndex, _trade.pairIndex, _positionSizeCollateral); // Charge fees on max(min position size, trade position size)

        values.closingFeeCollateral = _orderType != ITradingStorage.PendingOrderType.LIQ_CLOSE
            ? (values.positionSizeCollateral * _getMultiCollatDiamond().pairCloseFeeP(_trade.pairIndex)) / 100
                / ConstantsUtils.P_10
            : (_trade.collateralAmount * 5) / 100;

        values.triggerFeeCollateral = _orderType != ITradingStorage.PendingOrderType.LIQ_CLOSE
            ? (values.positionSizeCollateral * _getMultiCollatDiamond().pairTriggerOrderFeeP(_trade.pairIndex)) / 100
                / ConstantsUtils.P_10
            : values.closingFeeCollateral;

        // 2. Re-calculate current trader fee tier and apply it to closing fees
        updateFeeTierPoints(_trade.collateralIndex, _trade.user, _trade.pairIndex, _positionSizeCollateral);
        if (_orderType != ITradingStorage.PendingOrderType.LIQ_CLOSE) {
            values.closingFeeCollateral =
                _getMultiCollatDiamond().calculateFeeAmount(_trade.user, values.closingFeeCollateral);
            values.triggerFeeCollateral =
                _getMultiCollatDiamond().calculateFeeAmount(_trade.user, values.triggerFeeCollateral);
        }

        // 3. Calculate vault fee and GNS staking fee
        (values.reward2, values.reward3) =
            getClosingFeesCollateral(values.closingFeeCollateral, values.triggerFeeCollateral, _orderType);

        // 4. If trade collateral is enough to pay min fee, distribute closing fees (otherwise charged as negative PnL)
        values.collateralLeftInStorage = _trade.collateralAmount;

        if (values.collateralLeftInStorage >= values.reward3 + values.reward2) {
            distributeVaultFeeCollateral(_trade.collateralIndex, _trade.user, values.reward2);
            // distributeGnsStakingFeeCollateral(_trade.collateralIndex, _trade.user, values.reward3);

            if (!ConstantsUtils.isOrderTypeMarket(_orderType)) {
                values.gnsPriceCollateral = _getMultiCollatDiamond().getGnsPriceCollateralIndex(_trade.collateralIndex);

                // distributeTriggerFeeGns(
                //     _trade.user,
                //     _trade.collateralIndex,
                //     (values.triggerFeeCollateral * 2) / 10,
                //     values.gnsPriceCollateral,
                //     _getMultiCollatDiamond().getCollateral(_trade.collateralIndex).precisionDelta
                // );
            }

            values.collateralLeftInStorage -= values.reward3 + values.reward2;
        }
    }

    /**
     * @dev Distributes referral rewards and returns the amount charged in collateral tokens
     * @param _collateralIndex collateral index
     * @param _trader address of trader
     * @param _positionSizeCollateral position size in collateral tokens (collateral precision)
     * @param _pairOpenFeeP pair open fee percentage (1e10 precision)
     * @param _gnsPriceCollateral gns/collateral price (1e10 precision)
     */
    function distributeReferralFeeCollateral(
        uint8 _collateralIndex,
        address _trader,
        uint256 _positionSizeCollateral, // collateralPrecision
        uint256 _pairOpenFeeP,
        uint256 _gnsPriceCollateral
    ) public returns (uint256 rewardCollateral) {
        return _getMultiCollatDiamond().getCollateralFromUsdNormalizedValue(
            _collateralIndex,
            _getMultiCollatDiamond().distributeReferralReward(
                _trader,
                _getMultiCollatDiamond().getUsdNormalizedValue(_collateralIndex, _positionSizeCollateral),
                _pairOpenFeeP,
                _getMultiCollatDiamond().getGnsPriceUsd(_collateralIndex, _gnsPriceCollateral)
            )
        );
    }

    // Open interests

    /**
     * @dev Add open interest to the protocol (any amount)
     * @dev CAREFUL: this will reset the trade's borrowing fees to 0
     * @param _trade trade struct
     * @param _positionSizeCollateral position size in collateral tokens (collateral precision)
     */
    function addOiCollateral(ITradingStorage.Trade memory _trade, uint256 _positionSizeCollateral) public {
        _getMultiCollatDiamond().handleTradeBorrowingCallback(
            _trade.collateralIndex,
            _trade.user,
            _trade.pairIndex,
            _trade.index,
            _positionSizeCollateral,
            true,
            _trade.long
        );
        _getMultiCollatDiamond().addPriceImpactOpenInterest(_trade.user, _trade.index, _positionSizeCollateral);
    }

    /**
     * @dev Add trade position size OI to the protocol (for new trades)
     * @dev CAREFUL: this will reset the trade's borrowing fees to 0
     * @param _trade trade struct
     */
    function addTradeOiCollateral(ITradingStorage.Trade memory _trade) external {
        addOiCollateral(_trade, getPositionSizeCollateral(_trade.collateralAmount, _trade.leverage));
    }

    /**
     * @dev Remove open interest from the protocol (any amount)
     * @param _trade trade struct
     * @param _positionSizeCollateral position size in collateral tokens (collateral precision)
     */
    function removeOiCollateral(ITradingStorage.Trade memory _trade, uint256 _positionSizeCollateral) public {
        _getMultiCollatDiamond().handleTradeBorrowingCallback(
            _trade.collateralIndex,
            _trade.user,
            _trade.pairIndex,
            _trade.index,
            _positionSizeCollateral,
            false,
            _trade.long
        );
        _getMultiCollatDiamond().removePriceImpactOpenInterest(_trade.user, _trade.index, _positionSizeCollateral);
    }

    /**
     * @dev Remove trade position size OI from the protocol (for full close)
     * @param _trade trade struct
     */
    function removeTradeOiCollateral(ITradingStorage.Trade memory _trade) external {
        removeOiCollateral(_trade, getPositionSizeCollateral(_trade.collateralAmount, _trade.leverage));
    }

    /**
     * @dev Handles OI delta for an existing trade (for trade updates)
     * @param _trade trade struct
     * @param _newPositionSizeCollateral new position size in collateral tokens (collateral precision)
     */
    function handleOiDelta(ITradingStorage.Trade memory _trade, uint256 _newPositionSizeCollateral) external {
        uint256 existingPositionSizeCollateral = getPositionSizeCollateral(_trade.collateralAmount, _trade.leverage);

        if (_newPositionSizeCollateral > existingPositionSizeCollateral) {
            addOiCollateral(_trade, _newPositionSizeCollateral - existingPositionSizeCollateral);
        } else if (_newPositionSizeCollateral < existingPositionSizeCollateral) {
            removeOiCollateral(_trade, existingPositionSizeCollateral - _newPositionSizeCollateral);
        }
    }

    /**
     * @dev Returns current address as multi-collateral diamond interface to call other facets functions.
     */
    function _getMultiCollatDiamond() public view returns (IGNSMultiCollatDiamond) {
        return IGNSMultiCollatDiamond(address(this));
    }
}
