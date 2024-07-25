Order Close 的整个流程
1. check trading status -> Activated
2. 判断是否是 pending的order, 01789, 判断通过， orderid =4 
3. getTrade , 获取这笔订单， 并将order 存储成为pendingOrder
4. getPrice , 触发回调， closeTradeMarketCallback
5. getPendingOrder ， 获得之前 存储的pending的order
6. getTrade, 获取这笔交易, 验证状态
7. CancelReason.NONE => 正常取消
8. getPnlPercent - 根据openPrice , currentPrice ， 计算pnl (currentPrice-open) / openPrice
9. 执行unregister order 的逻辑
10. getPositionSizeCollateral -> processClosingFees
11. calculate pairCloseFee, pairTriggerFee ,
12. update user Fee Tier points
13. calculateFeeAmount (close fee + trigger fee )
14. getTradeValueCollateral , 计算borrowing Fee
    * getTradeBorrowingFeeCollateral， 计算用户的borrowing fee
15. handleTradePnl , 处理用户的pnl
    * sendAsset or receiveAsset
    * receiveAsset 后， accure interest
16. emit BorrowingFeeCharged
17. closeTrade , 计算用户当前的仓位
    * handleTradeBorrowingCallback
      *  计息
      *  _setPairPendingAccFees
      *  _setGroupPendingAccFees
      *  _updatePairOi
      *  _updateGroupOi
   *  removePriceImpactOpenInterest 
      *  _getCurrentWindowId
      *  calculate collateral usd
      *  remove old oi
      *  PriceImpactOpenInterestRemoved
18. emit TradeClosed, close order 结束
19. emit MarketExecuted , market order executed 
20. TradingCallbackExecuted
21. close Pending order