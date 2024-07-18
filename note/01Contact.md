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
   * 