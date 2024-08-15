// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "../abstract/GNSAddressStore.sol";

import "../../interfaces/libraries/ITradingInteractionsUtils.sol";
import "../../interfaces/types/ITradingStorage.sol";

import "../../libraries/TradingInteractionsUtils.sol";

/**
 * @dev Facet #7: Trading (user interactions)
 */
contract GNSTradingInteractions is GNSAddressStore, ITradingInteractionsUtils {
    // Initialization

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @inheritdoc ITradingInteractionsUtils
    function initializeTrading(uint16 _marketOrdersTimeoutBlocks, address[] memory _usersByPassTriggerLink)
        external
        reinitializer(8)
    {
        TradingInteractionsUtils.initializeTrading(_marketOrdersTimeoutBlocks, _usersByPassTriggerLink);
    }

    // Management Setters

    /// @inheritdoc ITradingInteractionsUtils
    function updateMarketOrdersTimeoutBlocks(uint16 _valueBlocks) external onlyRole(Role.GOV) {
        TradingInteractionsUtils.updateMarketOrdersTimeoutBlocks(_valueBlocks);
    }

    /// @inheritdoc ITradingInteractionsUtils
    function updateByPassTriggerLink(address[] memory _users, bool[] memory _shouldByPass)
        external
        onlyRole(Role.GOV)
    {
        TradingInteractionsUtils.updateByPassTriggerLink(_users, _shouldByPass);
    }

    // Interactions

    /// @inheritdoc ITradingInteractionsUtils
    function setTradingDelegate(address _delegate) external {
        TradingInteractionsUtils.setTradingDelegate(_delegate);
    }

    /// @inheritdoc ITradingInteractionsUtils
    function removeTradingDelegate() external {
        TradingInteractionsUtils.removeTradingDelegate();
    }

    /// @inheritdoc ITradingInteractionsUtils
    function delegatedTradingAction(address _trader, bytes calldata _callData) external returns (bytes memory) {
        return TradingInteractionsUtils.delegatedTradingAction(_trader, _callData);
    }

    function batchOpenTrade(ITradingStorage.Trade[] memory _trades, uint16 _maxSlippageP, address _referrer) external {
        for (uint256 i = 0; i < _trades.length; i++) {
            TradingInteractionsUtils.openTrade(_trades[i], _maxSlippageP, _referrer);
        }
    }

    /// @inheritdoc ITradingInteractionsUtils
    function openTrade(ITradingStorage.Trade memory _trade, uint16 _maxSlippageP, address _referrer) external {
        TradingInteractionsUtils.openTrade(_trade, _maxSlippageP, _referrer);
    }

    function batchOpenTradeNative(ITradingStorage.Trade[] memory _trades, uint16 _maxSlippageP, address _referrer)
        external
        payable
    {
        TradingInteractionsUtils.batchOpenTradeNative(_trades, _maxSlippageP, _referrer);
    }

    /// @inheritdoc ITradingInteractionsUtils
    function openTradeNative(ITradingStorage.Trade memory _trade, uint16 _maxSlippageP, address _referrer)
        external
        payable
    {
        TradingInteractionsUtils.openTradeNative(_trade, _maxSlippageP, _referrer);
    }

    /// @inheritdoc ITradingInteractionsUtils
    function batchReverseOrderMarket(uint32[] memory _indexList) external {
        for (uint256 i = 0; i < _indexList.length; i++) {
            TradingInteractionsUtils.reverseOrder(_indexList[i]);
        }
    }

    /// @inheritdoc ITradingInteractionsUtils
    function reverseOrderMarket(uint32 _index) external {
        TradingInteractionsUtils.reverseOrder(_index);
    }

    /// @inheritdoc ITradingInteractionsUtils
    function batchCloseTradeMarket(uint32[] memory _indexList) external {
        for (uint256 i = 0; i < _indexList.length; i++) {
            TradingInteractionsUtils.closeTradeMarket(_indexList[i]);
        }
    }

    /// @inheritdoc ITradingInteractionsUtils
    function closeTradeMarket(uint32 _index) external {
        TradingInteractionsUtils.closeTradeMarket(_index);
    }

    /// @inheritdoc ITradingInteractionsUtils
    function updateOpenOrder(uint32 _index, uint64 _triggerPrice, uint64 _tp, uint64 _sl, uint16 _maxSlippageP)
        external
    {
        TradingInteractionsUtils.updateOpenOrder(_index, _triggerPrice, _tp, _sl, _maxSlippageP);
    }

    /// @inheritdoc ITradingInteractionsUtils
    function cancelOpenOrder(uint32 _index) external {
        TradingInteractionsUtils.cancelOpenOrder(_index);
    }

    /// @inheritdoc ITradingInteractionsUtils
    function updateTp(uint32 _index, uint64 _newTp) external {
        TradingInteractionsUtils.updateTp(_index, _newTp);
    }

    /// @inheritdoc ITradingInteractionsUtils
    function updateSl(uint32 _index, uint64 _newSl) external {
        TradingInteractionsUtils.updateSl(_index, _newSl);
    }

    /// @inheritdoc ITradingInteractionsUtils
    function updateLeverage(uint32 _index, uint24 _newLeverage) external {
        TradingInteractionsUtils.updateLeverage(_index, _newLeverage);
    }

    /// @inheritdoc ITradingInteractionsUtils
    function increasePositionSize(
        uint32 _index,
        uint120 _collateralDelta,
        uint24 _leverageDelta,
        uint64 _expectedPrice,
        uint16 _maxSlippageP
    ) external {
        TradingInteractionsUtils.increasePositionSize(
            _index, _collateralDelta, _leverageDelta, _expectedPrice, _maxSlippageP
        );
    }

    /// @inheritdoc ITradingInteractionsUtils
    function decreasePositionSize(uint32 _index, uint120 _collateralDelta, uint24 _leverageDelta) external {
        TradingInteractionsUtils.decreasePositionSize(_index, _collateralDelta, _leverageDelta);
    }

    /// @inheritdoc ITradingInteractionsUtils
    function triggerOrder(uint256 _packed) external {
        TradingInteractionsUtils.triggerOrder(_packed);
    }

    /// @inheritdoc ITradingInteractionsUtils
    function cancelOrderAfterTimeout(uint32 _orderIndex) external {
        TradingInteractionsUtils.cancelOrderAfterTimeout(_orderIndex);
    }

    // Getters

    /// @inheritdoc ITradingInteractionsUtils
    function getWrappedNativeToken() external view returns (address) {
        return TradingInteractionsUtils.getWrappedNativeToken();
    }

    /// @inheritdoc ITradingInteractionsUtils
    function isWrappedNativeToken(address _token) external view returns (bool) {
        return TradingInteractionsUtils.isWrappedNativeToken(_token);
    }

    /// @inheritdoc ITradingInteractionsUtils
    function getTradingDelegate(address _trader) external view returns (address) {
        return TradingInteractionsUtils.getTradingDelegate(_trader);
    }

    /// @inheritdoc ITradingInteractionsUtils
    function getMarketOrdersTimeoutBlocks() external view returns (uint16) {
        return TradingInteractionsUtils.getMarketOrdersTimeoutBlocks();
    }

    /// @inheritdoc ITradingInteractionsUtils
    function getByPassTriggerLink(address _user) external view returns (bool) {
        return TradingInteractionsUtils.getByPassTriggerLink(_user);
    }
}
