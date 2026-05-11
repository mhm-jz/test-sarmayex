import '../../domain/entities/trading_realtime_entity.dart';
import '../models/trading_realtime_model.dart';
import 'market_mapper.dart';
import 'order_book_mapper.dart';

extension TradingRealtimeModelMapper on TradingRealtimeModel {
  TradingRealtimeEntity toEntity() {
    return switch (this) {
      MarketsRealtimeModel(:final markets) => MarketsRealtimeEntity(
          markets: markets
              .map((market) => market.toEntity())
              .toList(growable: false),
        ),
      OrderBookRealtimeModel(:final orderBook) => OrderBookRealtimeEntity(
          orderBook: orderBook.toEntity(),
        ),
    };
  }
}
