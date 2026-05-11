import 'package:sarmayex/features/data/models/order_book_entry.dart';

final class OrderBookModel {
  final String market;
  final List<OrderBookEntryModel> bids;
  final List<OrderBookEntryModel> asks;

  const OrderBookModel({
    required this.market,
    required this.bids,
    required this.asks,
  });

  factory OrderBookModel.fromJson({
    required String market,
    required Map<String, dynamic> json,
  }) {
    final rawBids = json['bids'];
    final rawAsks = json['asks'];

    if (rawBids is! List) {
      throw FormatException('Invalid bids payload: $json');
    }

    if (rawAsks is! List) {
      throw FormatException('Invalid asks payload: $json');
    }

    return OrderBookModel(
      market: market,
      bids: rawBids
          .map(OrderBookEntryModel.fromJsonValue)
          .toList(growable: false),
      asks: rawAsks
          .map(OrderBookEntryModel.fromJsonValue)
          .toList(growable: false),
    );
  }
}
