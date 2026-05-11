import '../../../domain/entities/market.dart';
import '../../../domain/entities/order_book_item_entity.dart';
import '../../../domain/failures/trading_failure.dart';

enum TradingConnectionStatus {
  initial,
  connecting,
  connected,
  reconnecting,
  failure,
}

final class TradingState {
  final String selectedMarket;
  final TradingConnectionStatus status;
  final List<MarketEntity> markets;
  final List<OrderBookItemEntity> bids;
  final List<OrderBookItemEntity> asks;
  final TradingFailure? failure;

  const TradingState({
    required this.selectedMarket,
    required this.status,
    required this.markets,
    required this.bids,
    required this.asks,
    this.failure,
  });

  factory TradingState.initial() {
    return const TradingState(
      selectedMarket: 'USDT_IRT',
      status: TradingConnectionStatus.initial,
      markets: [],
      bids: [],
      asks: [],
    );
  }

  TradingState copyWith({
    String? selectedMarket,
    TradingConnectionStatus? status,
    List<MarketEntity>? markets,
    List<OrderBookItemEntity>? bids,
    List<OrderBookItemEntity>? asks,
    TradingFailure? failure,
    bool clearFailure = false,
    bool clearOrderBook = false,
  }) {
    return TradingState(
      selectedMarket: selectedMarket ?? this.selectedMarket,
      status: status ?? this.status,
      markets: markets ?? this.markets,
      bids: clearOrderBook ? [] : bids ?? this.bids,
      asks: clearOrderBook ? [] : asks ?? this.asks,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}
