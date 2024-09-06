// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "../../interfaces/IERC20.sol";
import {ITradingInteractionsUtils} from "../../interfaces/libraries/ITradingInteractionsUtils.sol";
import {ITradingStorage} from "../../interfaces/types/ITradingStorage.sol";

contract CopyTrade {
    error ZeroValue();
    error NotOwner();
    error Overflow();

    address public bot_address;
    address public wsei_contract = 0xE30feDd158A2e3b13e9badaeABaFc5516e95e8C7;
    address trading_interaction = 0x43DaE8BB39d43F2fA7625715572C89c4d8ba26d6;
    
    // copier => trader => value
    mapping(address => mapping(address => uint256)) public delegates;

    // copier => trader => tradeId
    mapping(address => mapping(address => uint256)) public delegateId;

    constructor(address _bot) {
        bot_address = _bot;
    }

    modifier onlyBot() {
        if (msg.sender != bot_address) revert NotOwner();
        _;
    }

    // delegate sei token to trader
    function delegateTrade(address trader) external payable {
        uint256 nativeValue = msg.value;
        if (nativeValue == 0) {
            revert ZeroValue();
        }
        if (nativeValue > type(uint120).max) {
            revert Overflow();
        }
        IERC20(wsei_contract).deposit{value: nativeValue}();
        delegates[msg.sender][trader] += nativeValue;
    }

    // close trade
    function closeTrade(address trader,uint32 _tradeId) external {
        uint256 delegateValue = delegates[msg.sender][trader];
        if (delegateValue == 0) {
            revert ZeroValue();
        }
        ITradingInteractionsUtils(trading_interaction).closeTradeMarket(_tradeId);
        IERC20(wsei_contract).transfer(msg.sender, delegateValue);
        delegates[msg.sender][msg.sender] = 0;
    }

    // get all delegates
    function getAllDelegates(address copier) public view {}

    // bot call trigger copy trade
    function copyTrade(address _copier, address _trader, ITradingStorage.Trade memory _trade, uint16 _maxSlippageP)
        external
        onlyBot
    {
        uint256 delegateValue = delegates[_copier][_trader];
        if (delegateValue == 0) {
            revert ZeroValue();
        }

        IERC20(wsei_contract).approve(trading_interaction, delegateValue);
        _trade.collateralAmount = uint120(delegateValue);
        ITradingInteractionsUtils(trading_interaction).openTrade(_trade, _maxSlippageP, address(0));
    }

}
