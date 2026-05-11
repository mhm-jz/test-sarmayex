import 'order_book_item_entity.dart';

final class OrderBook {
  final String market;
  final List<OrderBookItemEntity> bids;
  final List<OrderBookItemEntity> asks;

  const OrderBook({
    required this.market,
    required this.bids,
    required this.asks,
  });
}
