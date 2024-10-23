// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../interfaces/IGNSMultiCollatDiamond.sol";
import "../interfaces/IERC20.sol";

import "./StorageUtils.sol";
import "./PackingUtils.sol";
import "./ChainUtils.sol";
import "./ConstantsUtils.sol";

import "./updateLeverage/UpdateLeverageLifecycles.sol";
import "./updatePositionSize/UpdatePositionSizeLifecycles.sol";

/**
 * @dev GNSTradingInteractions facet internal library
 */
library TradingInteractionsUtils {
    using PackingUtils for uint256;
    using SafeERC20 for IERC20;

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
     * @dev Modifier to prevent calling function from delegated action
     */
    modifier notDelegatedAction() {
        if (_getStorage().senderOverride != address(0)) revert ITradingInteractionsUtils.DelegatedActionNotAllowed();
        _;
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function initializeTrading(uint16 _marketOrdersTimeoutBlocks, address[] memory _usersByPassTriggerLink) internal {
        updateMarketOrdersTimeoutBlocks(_marketOrdersTimeoutBlocks);

        bool[] memory shouldByPass = new bool[](_usersByPassTriggerLink.length);
        for (uint256 i = 0; i < _usersByPassTriggerLink.length; i++) {
            shouldByPass[i] = true;
        }
        updateByPassTriggerLink(_usersByPassTriggerLink, shouldByPass);
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function updateMarketOrdersTimeoutBlocks(uint16 _valueBlocks) internal {
        if (_valueBlocks == 0) revert IGeneralErrors.ZeroValue();

        _getStorage().marketOrdersTimeoutBlocks = _valueBlocks;

        emit ITradingInteractionsUtils.MarketOrdersTimeoutBlocksUpdated(_valueBlocks);
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function updateByPassTriggerLink(address[] memory _users, bool[] memory _shouldByPass) internal {
        ITradingInteractions.TradingInteractionsStorage storage s = _getStorage();

        if (_users.length != _shouldByPass.length) revert IGeneralErrors.WrongLength();

        for (uint256 i = 0; i < _users.length; i++) {
            address user = _users[i];
            bool value = _shouldByPass[i];

            s.byPassTriggerLink[user] = value;

            emit ITradingInteractionsUtils.ByPassTriggerLinkUpdated(user, value);
        }
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function setTradingDelegate(address _delegate) internal {
        if (_delegate == address(0)) revert IGeneralErrors.ZeroAddress();
        _getStorage().delegations[msg.sender] = _delegate;
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function removeTradingDelegate() internal {
        delete _getStorage().delegations[msg.sender];
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function delegatedTradingAction(address _trader, bytes calldata _callData)
        internal
        notDelegatedAction
        returns (bytes memory)
    {
        ITradingInteractions.TradingInteractionsStorage storage s = _getStorage();

        if (s.delegations[_trader] != msg.sender) revert ITradingInteractionsUtils.DelegateNotApproved();

        s.senderOverride = _trader;
        (bool success, bytes memory result) = address(this).delegatecall(_callData);

        if (!success) {
            if (result.length < 4) revert(); // not a custom error (4 byte signature) or require() message

            assembly {
                let len := mload(result)
                revert(add(result, 0x20), len)
            }
        }

        s.senderOverride = address(0);

        return result;
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function openTrade(ITradingStorage.Trade memory _trade, uint16 _maxSlippageP, address _referrer)
        internal
        tradingActivated
    {
        _openTrade(_trade, _maxSlippageP, _referrer, false);
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function openTradeNative(ITradingStorage.Trade memory _trade, uint16 _maxSlippageP, address _referrer)
        internal
        tradingActivated
        notDelegatedAction
    {
        _trade.collateralAmount = _wrapNativeToken(_trade.collateralIndex);

        _openTrade(_trade, _maxSlippageP, _referrer, true);
    }

    function batchOpenTradeNative(ITradingStorage.Trade[] memory _trades, uint16 _maxSlippageP, address _referrer)
        internal
        tradingActivated
        notDelegatedAction
    {
        uint120 totalCollateralAmt = _wrapNativeToken(_trades[0].collateralIndex);
        uint120 totalOpenAmt = 0;
        for (uint8 i = 0; i < _trades.length; i++) {
            totalOpenAmt += _trades[i].collateralAmount;
        }
        require(totalCollateralAmt >= totalOpenAmt, "Insufficient collateral amount");
        for (uint8 i = 0; i < _trades.length; i++) {
            _openTrade(_trades[i], _maxSlippageP, _referrer, true);
        }
    }

    function reverseOrder(uint32 _index) internal tradingActivatedOrCloseOnly {
        address sender = _msgSender();
        ITradingStorage.Trade memory t = _getMultiCollatDiamond().getTrade(sender, _index);
        ITradingStorage.PendingOrder memory pendingOrder;
        pendingOrder.trade.user = t.user;
        pendingOrder.trade.index = t.index;
        pendingOrder.trade.pairIndex = t.pairIndex;
        pendingOrder.user = sender;
        pendingOrder.orderType = ITradingStorage.PendingOrderType.MARKET_REVERSE;

        pendingOrder = _getMultiCollatDiamond().storePendingOrder(pendingOrder);
        ITradingStorage.Id memory orderId = ITradingStorage.Id({user: pendingOrder.user, index: pendingOrder.index});
        _getMultiCollatDiamond().getPrice(
            t.collateralIndex,
            t.pairIndex,
            orderId,
            pendingOrder.orderType,
            TradingCommonUtils.getPositionSizeCollateral(t.collateralAmount, t.leverage),
            ChainUtils.getBlockNumber()
        );
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function closeTradeMarket(uint32 _index) internal tradingActivatedOrCloseOnly {
        address sender = _msgSender();

        TradingCommonUtils.revertIfTradeHasPendingMarketOrder(sender, _index);

        ITradingStorage.Trade memory t = _getMultiCollatDiamond().getTrade(sender, _index);
        ITradingStorage.PendingOrder memory pendingOrder;
        pendingOrder.trade.user = t.user;
        pendingOrder.trade.index = t.index;
        pendingOrder.trade.pairIndex = t.pairIndex;
        pendingOrder.user = sender;
        pendingOrder.orderType = ITradingStorage.PendingOrderType.MARKET_CLOSE;

        pendingOrder = _getMultiCollatDiamond().storePendingOrder(pendingOrder);
        ITradingStorage.Id memory orderId = ITradingStorage.Id({user: pendingOrder.user, index: pendingOrder.index});

        _getMultiCollatDiamond().getPrice(
            t.collateralIndex,
            t.pairIndex,
            orderId,
            pendingOrder.orderType,
            TradingCommonUtils.getPositionSizeCollateral(t.collateralAmount, t.leverage),
            ChainUtils.getBlockNumber()
        );

        emit ITradingInteractionsUtils.MarketOrderInitiated(orderId, sender, t.pairIndex, false);
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function updateOpenOrder(uint32 _index, uint64 _openPrice, uint64 _tp, uint64 _sl, uint16 _maxSlippageP)
        internal
        tradingActivated
    {
        address sender = _msgSender();
        ITradingStorage.Trade memory o = _getMultiCollatDiamond().getTrade(sender, _index);

        _checkNoPendingTrigger(
            ITradingStorage.Id({user: o.user, index: o.index}), ConstantsUtils.getPendingOpenOrderType(o.tradeType)
        );

        _getMultiCollatDiamond().updateOpenOrderDetails(
            ITradingStorage.Id({user: o.user, index: o.index}), _openPrice, _tp, _sl, _maxSlippageP
        );

        emit ITradingInteractionsUtils.OpenLimitUpdated(
            sender, o.pairIndex, _index, _openPrice, _tp, _sl, _maxSlippageP
        );
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function cancelOpenOrder(uint32 _index) internal tradingActivatedOrCloseOnly {
        address sender = _msgSender();
        ITradingStorage.Trade memory o = _getMultiCollatDiamond().getTrade(sender, _index);
        ITradingStorage.Id memory tradeId = ITradingStorage.Id({user: o.user, index: o.index});

        if (o.tradeType == ITradingStorage.TradeType.TRADE) revert IGeneralErrors.WrongTradeType();

        _checkNoPendingTrigger(tradeId, ConstantsUtils.getPendingOpenOrderType(o.tradeType));

        _getMultiCollatDiamond().closeTrade(tradeId);

        TradingCommonUtils.transferCollateralTo(o.collateralIndex, sender, o.collateralAmount);

        emit ITradingInteractionsUtils.OpenLimitCanceled(sender, o.pairIndex, _index);
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function updateTp(uint32 _index, uint64 _newTp) internal tradingActivated {
        address sender = _msgSender();

        ITradingStorage.Trade memory t = _getMultiCollatDiamond().getTrade(sender, _index);
        ITradingStorage.Id memory tradeId = ITradingStorage.Id({user: t.user, index: t.index});

        _checkNoPendingTrigger(tradeId, ITradingStorage.PendingOrderType.TP_CLOSE);

        _getMultiCollatDiamond().updateTradeTp(tradeId, _newTp);
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function updateSl(uint32 _index, uint64 _newSl) internal tradingActivated {
        address sender = _msgSender();

        ITradingStorage.Trade memory t = _getMultiCollatDiamond().getTrade(sender, _index);
        ITradingStorage.Id memory tradeId = ITradingStorage.Id({user: t.user, index: t.index});

        _checkNoPendingTrigger(tradeId, ITradingStorage.PendingOrderType.SL_CLOSE);

        _getMultiCollatDiamond().updateTradeSl(tradeId, _newSl);
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function updateLeverage(uint32 _index, uint24 _newLeverage) internal tradingActivated {
        UpdateLeverageLifecycles.requestUpdateLeverage(
            IUpdateLeverage.UpdateLeverageInput(_msgSender(), _index, _newLeverage)
        );
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function increasePositionSize(
        uint32 _index,
        uint120 _collateralDelta,
        uint24 _leverageDelta,
        uint64 _expectedPrice,
        uint16 _maxSlippageP
    ) internal tradingActivated {
        UpdatePositionSizeLifecycles.requestIncreasePositionSize(
            IUpdatePositionSize.IncreasePositionSizeInput(
                _msgSender(), _index, _collateralDelta, _leverageDelta, _expectedPrice, _maxSlippageP
            )
        );
    }

    function increasePositionSizePayable(
        uint32 _index,
        uint120 _collateralDelta,
        uint24 _leverageDelta,
        uint64 _expectedPrice,
        uint16 _maxSlippageP
    ) internal tradingActivated {
        _collateralDelta = _wrapNativeToken(0);
        UpdatePositionSizeLifecycles.requestIncreasePositionSizePayable(
            IUpdatePositionSize.IncreasePositionSizeInput(
                _msgSender(), _index, _collateralDelta, _leverageDelta, _expectedPrice, _maxSlippageP
            )
        );
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function decreasePositionSize(uint32 _index, uint120 _collateralDelta, uint24 _leverageDelta)
        internal
        tradingActivatedOrCloseOnly
    {
        UpdatePositionSizeLifecycles.requestDecreasePositionSize(
            IUpdatePositionSize.DecreasePositionSizeInput(_msgSender(), _index, _collateralDelta, _leverageDelta)
        );
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function triggerOrder(uint256 _packed) internal notDelegatedAction {
        (uint8 _orderType, address _trader, uint32 _index) = _packed.unpackTriggerOrder();

        ITradingStorage.PendingOrderType orderType = ITradingStorage.PendingOrderType(_orderType);

        if (ConstantsUtils.isOrderTypeMarket(orderType)) revert ITradingInteractionsUtils.WrongOrderType();

        bool isOpenLimit = orderType == ITradingStorage.PendingOrderType.LIMIT_OPEN
            || orderType == ITradingStorage.PendingOrderType.STOP_OPEN;

        ITradingStorage.TradingActivated activated = _getMultiCollatDiamond().getTradingActivated();
        if (
            (isOpenLimit && activated != ITradingStorage.TradingActivated.ACTIVATED)
                || (!isOpenLimit && activated == ITradingStorage.TradingActivated.PAUSED)
        ) {
            revert IGeneralErrors.Paused();
        }

        ITradingStorage.Trade memory t = _getMultiCollatDiamond().getTrade(_trader, _index);
        if (!t.isOpen) revert ITradingInteractionsUtils.NoTrade();

        if (orderType == ITradingStorage.PendingOrderType.LIQ_CLOSE && t.sl > 0) {
            uint256 liqPrice = TradingCommonUtils.getTradeLiquidationPrice(t, true);

            // If liq price not closer than SL, turn order into a SL order
            if ((t.long && liqPrice <= t.sl) || (!t.long && liqPrice >= t.sl)) {
                orderType = ITradingStorage.PendingOrderType.SL_CLOSE;
            }
        }

        _checkNoPendingTrigger(ITradingStorage.Id({user: t.user, index: t.index}), orderType);

        address sender = _msgSender();
        bool byPassesLinkCost = _getStorage().byPassTriggerLink[sender];

        uint256 positionSizeCollateral = TradingCommonUtils.getPositionSizeCollateral(t.collateralAmount, t.leverage);

        if (isOpenLimit) {
            uint256 leveragedPosUsd =
                _getMultiCollatDiamond().getUsdNormalizedValue(t.collateralIndex, positionSizeCollateral);
            (uint256 priceImpactP,) =
                _getMultiCollatDiamond().getTradePriceImpact(0, t.pairIndex, t.long, leveragedPosUsd);

            if ((priceImpactP * t.leverage) / 1e3 > ConstantsUtils.MAX_OPEN_NEGATIVE_PNL_P) {
                revert ITradingInteractionsUtils.PriceImpactTooHigh();
            }
        }

        if (!byPassesLinkCost) {
            IERC20(_getMultiCollatDiamond().getChainlinkToken()).safeTransferFrom(
                sender,
                address(this),
                _getMultiCollatDiamond().getLinkFee(t.collateralIndex, t.pairIndex, positionSizeCollateral)
            );
        }

        ITradingStorage.PendingOrder memory pendingOrder;
        pendingOrder.trade.user = t.user;
        pendingOrder.trade.index = t.index;
        pendingOrder.trade.pairIndex = t.pairIndex;
        pendingOrder.user = sender;
        pendingOrder.orderType = orderType;

        pendingOrder = _getMultiCollatDiamond().storePendingOrder(pendingOrder);

        ITradingStorage.Id memory orderId = ITradingStorage.Id({user: pendingOrder.user, index: pendingOrder.index});

        _getPriceTriggerOrder(t, orderId, orderType, byPassesLinkCost ? 0 : positionSizeCollateral);

        emit ITradingInteractionsUtils.TriggerOrderInitiated(orderId, _trader, t.pairIndex, byPassesLinkCost);
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function cancelOrderAfterTimeout(uint32 _orderIndex) internal tradingActivatedOrCloseOnly {
        address sender = _msgSender();

        ITradingStorage.Id memory orderId = ITradingStorage.Id({user: sender, index: _orderIndex});
        ITradingStorage.PendingOrder memory order = _getMultiCollatDiamond().getPendingOrder(orderId);
        ITradingStorage.Trade memory pendingTrade = order.trade;
        ITradingStorage.Trade memory trade = _getMultiCollatDiamond().getTrade(pendingTrade.user, pendingTrade.index);

        if (!order.isOpen) revert ITradingInteractionsUtils.NoOrder();

        if (!ConstantsUtils.isOrderTypeMarket(order.orderType)) revert ITradingInteractionsUtils.WrongOrderType();

        if (ChainUtils.getBlockNumber() < order.createdBlock + _getStorage().marketOrdersTimeoutBlocks) {
            revert ITradingInteractionsUtils.WaitTimeout();
        }

        _getMultiCollatDiamond().closePendingOrder(orderId);

        if (order.orderType == ITradingStorage.PendingOrderType.MARKET_OPEN) {
            TradingCommonUtils.transferCollateralTo(
                pendingTrade.collateralIndex, pendingTrade.user, pendingTrade.collateralAmount
            ); // send back collateral amount to user when cancelling market open
        } else if (
            order.orderType == ITradingStorage.PendingOrderType.UPDATE_LEVERAGE
                && pendingTrade.leverage < trade.leverage
        ) {
            TradingCommonUtils.transferCollateralTo(
                trade.collateralIndex,
                pendingTrade.user,
                pendingTrade.collateralAmount // send back collateral delta to user when cancelling leverage decrease
            );
        } else if (order.orderType == ITradingStorage.PendingOrderType.MARKET_PARTIAL_OPEN) {
            TradingCommonUtils.transferCollateralTo(
                trade.collateralIndex,
                pendingTrade.user,
                pendingTrade.collateralAmount // send back collateral delta to user when cancelling position size increase
            );
        }

        emit ITradingInteractionsUtils.ChainlinkCallbackTimeout(
            orderId,
            order.orderType == ITradingStorage.PendingOrderType.MARKET_OPEN ? pendingTrade.pairIndex : trade.pairIndex
        );
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function getWrappedNativeToken() internal view returns (address) {
        return ChainUtils.getWrappedNativeToken();
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function isWrappedNativeToken(address _token) internal view returns (bool) {
        return ChainUtils.isWrappedNativeToken(_token);
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function getTradingDelegate(address _trader) internal view returns (address) {
        return _getStorage().delegations[_trader];
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function getMarketOrdersTimeoutBlocks() internal view returns (uint16) {
        return _getStorage().marketOrdersTimeoutBlocks;
    }

    /**
     * @dev Check ITradingInteractionsUtils interface for documentation
     */
    function getByPassTriggerLink(address _user) internal view returns (bool) {
        return _getStorage().byPassTriggerLink[_user];
    }

    /**
     * @dev Returns storage slot to use when fetching storage relevant to library
     */
    function _getSlot() internal pure returns (uint256) {
        return StorageUtils.GLOBAL_TRADING_SLOT;
    }

    /**
     * @dev Returns storage pointer for storage struct in diamond contract, at defined slot
     */
    function _getStorage() internal pure returns (ITradingInteractions.TradingInteractionsStorage storage s) {
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
     * @dev Internal function for openTrade and openTradeNative
     * @param _trade trade data
     * @param _maxSlippageP max slippage percentage (1e3 precision)
     * @param _referrer referrer address
     * @param _isNative if true we skip the collateral transfer from user to contract
     */
    function _openTrade(ITradingStorage.Trade memory _trade, uint16 _maxSlippageP, address _referrer, bool _isNative)
        internal
    {
        address sender = _msgSender();
        _trade.user = sender;
        _trade.__placeholder = 0;

        // 1.  positionSize = collaterAmt * leverage
        uint256 positionSizeCollateral =
            TradingCommonUtils.getPositionSizeCollateral(_trade.collateralAmount, _trade.leverage);
        // 2. usd = value * price * delta
        uint256 positionSizeUsd =
            _getMultiCollatDiamond().getUsdNormalizedValue(_trade.collateralIndex, positionSizeCollateral);
        // 3. check pos size is in the correct size
        if (
            !TradingCommonUtils.isWithinExposureLimits(
                _trade.collateralIndex, _trade.pairIndex, _trade.long, positionSizeCollateral
            )
        ) revert ITradingInteractionsUtils.AboveExposureLimits();

        // 4.Trade collateral usd value needs to be >= 5x min trade fee usd (collateral left after trade opened >= 80%)
        if ((positionSizeUsd * 1e3) / _trade.leverage < 5 * _getMultiCollatDiamond().pairMinFeeUsd(_trade.pairIndex)) {
            revert ITradingInteractionsUtils.InsufficientCollateral();
        }

        // 5. check the leverage
        if (
            _trade.leverage < _getMultiCollatDiamond().pairMinLeverage(_trade.pairIndex) * 1e3
                || _trade.leverage > _getMultiCollatDiamond().pairMaxLeverage(_trade.pairIndex) * 1e3
        ) revert ITradingInteractionsUtils.WrongLeverage();

        // 6. update price Impact
        (uint256 priceImpactP,) =
            _getMultiCollatDiamond().getTradePriceImpact(0, _trade.pairIndex, _trade.long, positionSizeUsd);

        // 7. check price
        if ((priceImpactP * _trade.leverage) / 1e3 > ConstantsUtils.MAX_OPEN_NEGATIVE_PNL_P) {
            revert ITradingInteractionsUtils.PriceImpactTooHigh();
        }
        // 8. if native token , transfer native token
        if (!_isNative) {
            TradingCommonUtils.transferCollateralFrom(_trade.collateralIndex, sender, _trade.collateralAmount);
        }

        // 9. check trade type,
        // 9.1 check order type , if market order, store trade info
        if (_trade.tradeType != ITradingStorage.TradeType.TRADE) {
            ITradingStorage.TradeInfo memory tradeInfo;
            tradeInfo.maxSlippageP = _maxSlippageP;

            _trade = _getMultiCollatDiamond().storeTrade(_trade, tradeInfo);

            emit ITradingInteractionsUtils.OpenOrderPlaced(sender, _trade.pairIndex, _trade.index);
        } else {
            // 9.2 else  store trade to pending order , and wait
            ITradingStorage.PendingOrder memory pendingOrder;
            pendingOrder.trade = _trade;
            pendingOrder.user = sender;
            pendingOrder.orderType = ITradingStorage.PendingOrderType.MARKET_OPEN;
            pendingOrder.maxSlippageP = _maxSlippageP;

            pendingOrder = _getMultiCollatDiamond().storePendingOrder(pendingOrder);

            ITradingStorage.Id memory orderId = ITradingStorage.Id({user: pendingOrder.user, index: pendingOrder.index});

            _getMultiCollatDiamond().getPrice(
                _trade.collateralIndex,
                _trade.pairIndex,
                orderId,
                pendingOrder.orderType,
                positionSizeCollateral,
                ChainUtils.getBlockNumber()
            );

            emit ITradingInteractionsUtils.MarketOrderInitiated(orderId, sender, _trade.pairIndex, true);
        }

        if (_referrer != address(0)) {
            _getMultiCollatDiamond().registerPotentialReferrer(sender, _referrer);
        }
    }

    /**
     * @dev Revert if there is an active pending order for the trade
     * @param _tradeId trade id
     * @param _orderType order type
     */
    function _checkNoPendingTrigger(ITradingStorage.Id memory _tradeId, ITradingStorage.PendingOrderType _orderType)
        internal
        view
    {
        if (
            _getMultiCollatDiamond().hasActiveOrder(
                _getMultiCollatDiamond().getTradePendingOrderBlock(_tradeId, _orderType)
            )
        ) revert ITradingInteractionsUtils.PendingTrigger();
    }

    /**
     * @dev Initiate price aggregator request for trigger order
     * @param _trade trade
     * @param _orderId order id
     * @param _orderType order type
     * @param _positionSizeCollateral position size in collateral tokens (collateral precision)
     */
    function _getPriceTriggerOrder(
        ITradingStorage.Trade memory _trade,
        ITradingStorage.Id memory _orderId,
        ITradingStorage.PendingOrderType _orderType,
        uint256 _positionSizeCollateral // collateral precision
    ) internal {
        ITradingStorage.TradeInfo memory tradeInfo = _getMultiCollatDiamond().getTradeInfo(_trade.user, _trade.index);

        _getMultiCollatDiamond().getPrice(
            _trade.collateralIndex,
            _trade.pairIndex,
            _orderId,
            _orderType,
            _positionSizeCollateral,
            _orderType == ITradingStorage.PendingOrderType.SL_CLOSE
                ? tradeInfo.slLastUpdatedBlock
                : _orderType == ITradingStorage.PendingOrderType.TP_CLOSE
                    ? tradeInfo.tpLastUpdatedBlock
                    : tradeInfo.createdBlock
        );
    }

    /**
     * @dev Receives native token and sends back wrapped token to user
     * @param _collateralIndex index of the collateral
     */
    function _wrapNativeToken(uint8 _collateralIndex) internal returns (uint120) {
        address collateral = _getMultiCollatDiamond().getCollateral(_collateralIndex).collateral;
        uint256 nativeValue = msg.value;

        if (nativeValue == 0) {
            revert IGeneralErrors.ZeroValue();
        }

        if (nativeValue > type(uint120).max) {
            revert IGeneralErrors.Overflow();
        }

        if (!ChainUtils.isWrappedNativeToken(collateral)) {
            revert ITradingInteractionsUtils.NotWrappedNativeToken();
        }

        IERC20(collateral).deposit{value: nativeValue}();

        emit ITradingInteractionsUtils.NativeTokenWrapped(msg.sender, nativeValue);

        return uint120(nativeValue);
    }

    /**
     * @dev Returns the caller of the transaction (overriden by trader address if delegatedAction is called)
     */
    function _msgSender() internal view returns (address) {
        address senderOverride = _getStorage().senderOverride;
        if (senderOverride == address(0)) {
            return msg.sender;
        } else {
            return senderOverride;
        }
    }
}
