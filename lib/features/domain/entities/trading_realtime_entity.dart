import 'market.dart';
import 'order_book.dart';

sealed class TradingRealtimeEntity {
  const TradingRealtimeEntity();
}

final class MarketsRealtimeEntity extends TradingRealtimeEntity {
  final List<MarketEntity> markets;

  const MarketsRealtimeEntity({
    required this.markets,
  });
}

final class OrderBookRealtimeEntity extends TradingRealtimeEntity {
  final OrderBook orderBook;

  const OrderBookRealtimeEntity({
    required this.orderBook,
  });
}
