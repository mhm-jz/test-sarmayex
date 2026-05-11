import 'package:sarmayex/features/data/models/order_book_entry.dart';

import '../../domain/entities/order_book.dart';
import '../../domain/entities/order_book_item_entity.dart';
import '../models/order_book_model.dart';

extension OrderBookEntryModelMapper on OrderBookEntryModel {
  OrderBookItemEntity toEntity() {
    return OrderBookItemEntity(
      price: price,
      amount: amount,
    );
  }
}

extension OrderBookModelMapper on OrderBookModel {
  OrderBook toEntity() {
    return OrderBook(
      market: market,
      bids: bids.map((entry) => entry.toEntity()).toList(growable: false),
      asks: asks.map((entry) => entry.toEntity()).toList(growable: false),
    );
  }
}
