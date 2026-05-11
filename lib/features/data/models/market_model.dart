final class MarketModel {
  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final double lastPrice;
  final double changePercent;

  const MarketModel({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.lastPrice,
    required this.changePercent,
  });

  factory MarketModel.fromSymbolChange({
    required String symbol,
    required Map<String, dynamic> json,
  }) {
    final parts = symbol.split('_');

    if (parts.length != 2) {
      throw FormatException('Invalid market symbol: $symbol');
    }

    final rawLastPrice = json['lp'];
    final rawChangePercent = json['pct'];

    if (rawLastPrice == null) {
      throw FormatException('Missing last price for market $symbol: $json');
    }

    if (rawChangePercent == null) {
      throw FormatException('Missing change percent for market $symbol: $json');
    }

    final lastPrice = double.tryParse(rawLastPrice.toString());
    final changePercent = double.tryParse(rawChangePercent.toString());

    if (lastPrice == null) {
      throw FormatException('Invalid last price for market $symbol: $json');
    }

    if (changePercent == null) {
      throw FormatException('Invalid change percent for market $symbol: $json');
    }

    return MarketModel(
      symbol: symbol,
      baseAsset: parts.first,
      quoteAsset: parts.last,
      lastPrice: lastPrice,
      changePercent: changePercent,
    );
  }
}
