sealed class TradingDataException implements Exception {
  const TradingDataException();
}

final class TradingDataNetworkException extends TradingDataException {
  const TradingDataNetworkException();
}

final class TradingDataUnauthorizedException extends TradingDataException {
  const TradingDataUnauthorizedException();
}

final class TradingDataInvalidMarketException extends TradingDataException {
  final String? market;

  const TradingDataInvalidMarketException({
    this.market,
  });
}

final class TradingDataServerException extends TradingDataException {
  final int statusCode;

  const TradingDataServerException({
    required this.statusCode,
  });
}

final class TradingDataInvalidContentTypeException
    extends TradingDataException {
  final String? contentType;

  const TradingDataInvalidContentTypeException({
    this.contentType,
  });
}

final class TradingDataIdleTimeoutException extends TradingDataException {
  const TradingDataIdleTimeoutException();
}

final class TradingDataParseException extends TradingDataException {
  final String? event;
  final String rawData;

  const TradingDataParseException({
    required this.event,
    required this.rawData,
  });
}

final class TradingDataUnknownException extends TradingDataException {
  final Object error;

  const TradingDataUnknownException({
    required this.error,
  });
}
