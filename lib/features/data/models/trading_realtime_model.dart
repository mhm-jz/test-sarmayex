import 'market_model.dart';
import 'order_book_model.dart';

sealed class TradingRealtimeModel {
  const TradingRealtimeModel();
}

final class MarketsRealtimeModel extends TradingRealtimeModel {
  final List<MarketModel> markets;

  const MarketsRealtimeModel({
    required this.markets,
  });
}

final class OrderBookRealtimeModel extends TradingRealtimeModel {
  final OrderBookModel orderBook;

  const OrderBookRealtimeModel({
    required this.orderBook,
  });
}
