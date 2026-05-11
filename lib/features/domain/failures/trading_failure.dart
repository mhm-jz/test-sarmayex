sealed class TradingFailure {
  const TradingFailure();
}

final class TradingNetworkFailure extends TradingFailure {
  const TradingNetworkFailure();
}

final class TradingUnauthorizedFailure extends TradingFailure {
  const TradingUnauthorizedFailure();
}

final class TradingInvalidMarketFailure extends TradingFailure {
  final String? market;

  const TradingInvalidMarketFailure({
    this.market,
  });
}

final class TradingServerFailure extends TradingFailure {
  final int statusCode;

  const TradingServerFailure({
    required this.statusCode,
  });
}

final class TradingInvalidContentTypeFailure extends TradingFailure {
  final String? contentType;

  const TradingInvalidContentTypeFailure({
    this.contentType,
  });
}

final class TradingIdleTimeoutFailure extends TradingFailure {
  const TradingIdleTimeoutFailure();
}

final class TradingDataParseFailure extends TradingFailure {
  const TradingDataParseFailure();
}

final class TradingUnknownFailure extends TradingFailure {
  final Object error;

  const TradingUnknownFailure({
    required this.error,
  });
}
