Market Order 的创建过程
1. openTradeNative open Order 方法调用, 140倍杠杆
2. deposit 4 sei -> 4 wsei
3. getPositionSizeCollateral， 4 sei * 140 leverage = 560 sei
4. get getUsdNormalizedValue (latestRoundData 0.35200282 )  560 * 0.352 = 197.12  U
5. isWithinExposureLimits 
   * getPairOiCollateral(648e18) + position < getPairMaxOiCollateral(7000000e18)     
   * withinMaxBorrowingGroupOi
6. require( position/ leverage ) > 5*fee
7. 2 < leverage <150
8. Trade price Impact 
   * Price impact (%) = (Open interest {long/short} + New trade position size / 2) / 1% depth {above/below}.
   * Open interest = 遍历当前几个window, 对几个window 进行oi 的求和
9. 判断是否大于最大的pnl， 如果大于，这个订单太大，开不了仓
10. check order , 判断order type 
11. 如果是 market trade 类型的order , 先存储成为 pending order
12. getPrice , get pairSpreadP, 执行call back的逻辑
13. MARKET_OPEN -> openTradeMarketCallback
14. 根据 order id ，获取 pending Order
15. 执行open trade perp 逻辑， 判断订单能否通过
16. 根据 spreadP 计算market execute price, price * (1+spreadP)， spreadP 通常为0， 
17. 根据新的market exeuction price 计算新的price impact (oi+pos)/2 / depth
18. check order status
    * market price result
    * maxSlippage ?
    * withIn exposure
    * leverage
19.  上面的检查通过后， 可以 _registerTrade这笔trade 的交易
20.  计算开仓费 openingFees processOpeningFees
21.  仓位需大于 min position (100 U)
22.  update trader fee tier points
23.  getGovFeeCollateral -> 分配gov Fee , collateralAmt * openFeeP = 560 * 0.0003 = 0.168 
24.  distributeExactGovFeeCollateral -> GovFeeCharged
25.  计算一笔trigger order fee  560 * 0.0002 = 0.112
26.  charge 成功， 结束openingFee , store 这笔trade
27.  validate trade , 判断抵押品状态, tp/sl 是否正确
28.  验证通过，添加到当前的盘口中， addOiCollateral
29.  addOi -> handleTradeBorrowingCallback , 处理 borrowing fee logic
30.  处理完borring fee, 更新price impact 的open interest
31.  handle Oi logic , add trader oi, addDeltaOi
32.  至此， 完成一笔trade 的store 
33.  emit MarketExecuted , 市价单， 执行成功
34.  执行closePendingOrder的逻辑， 关闭之前创建的pending status的订单
