
import '../../domain/entities/market.dart';
import '../models/market_model.dart';

extension MarketModelMapper on MarketModel {
  MarketEntity toEntity() {
    return MarketEntity(
      symbol: symbol,
      baseAsset: baseAsset,
      quoteAsset: quoteAsset,
      lastPrice: lastPrice,
      changePercent: changePercent,
    );
  }
}
