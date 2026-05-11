import 'package:equatable/equatable.dart';

final class MarketEntity extends Equatable {
  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final double? lastPrice;
  final double? changePercent;

  const MarketEntity({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    this.lastPrice,
    this.changePercent,
  });

  @override
  List<Object?> get props => [
    symbol,
    baseAsset,
    quoteAsset,
    lastPrice,
    changePercent,
  ];
}