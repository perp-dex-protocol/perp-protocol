合约解析
1. PairStorage 
   * pairs 真实交易对交易对
   * groups 交易种类, 股票/大宗商品/crypto
   * fees 根据group 定义的手续费

2. Referral

3. FeeTier
   *  根据不同的group , 下面的收费详情数据
   *  feeMultiplier 倍数
   *  pointsThreshold 积分
   *  updateTraderPoints 更新交易员的 积分数据， 主要是根据交易量计算
  
4. PriceImpact
   *  持仓量与价格深度的计算逻辑
  
5. TradingStorage
   * Trading 状态 ACTIVATED/CLOSE_ONLY
   * 添加抵押品 , token 与 fToken, 抵押品状态 ,精度， delta
   * 交易的存储, 交易的更新， 更新仓位的信息，止盈(tp)止损(sl),滑点的价格
   * 关闭交易
   * pendingOrder的存储(限价单)， 与关闭
   * 交易信息的查询与用户信息的统计信息
  
6. TriggerRewards
   * 分发 token 合约激励

7. TradingInteractions
   * openTrade openTradeNative 开仓
   * closeTradeMarket, 根据user 的index close 仓位
   * updateOpenOrder 更新订单信息 /  cancel 取消订单
   * increasePositionSize / decreasePositionSize 仓位大小的更新
   * triggerOrder 根据 订单类型/ trader address / index , 触发订单成交

8. TradingCallbacks
   * 订单异常的callback 合约
  
9. BorrowingFees
   * 借款的时候， 持续计息， callback 时计算borrowFee
   * setBorrowingPairParams(uint8 _collateralIndex, uint16 _pairIndex, BorrowingPairParams calldata _value)
   
   * setBorrowingGroupParams
      feePerBlock  maxOi  feeExponent
10. PriceAggregator
   *  获取价格 getPrice