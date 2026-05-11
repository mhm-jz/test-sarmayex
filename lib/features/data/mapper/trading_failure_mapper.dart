import 'package:sarmayex/features/data/exception/trading_data_exception.dart';

import '../../domain/failures/trading_failure.dart';

TradingFailure mapDataExceptionToTradingFailure(
  TradingDataException exception,
) {
  return switch (exception) {
    TradingDataNetworkException() => const TradingNetworkFailure(),
    TradingDataUnauthorizedException() => const TradingUnauthorizedFailure(),
    TradingDataInvalidMarketException(:final market) =>
      TradingInvalidMarketFailure(market: market),
    TradingDataServerException(:final statusCode) =>
      TradingServerFailure(statusCode: statusCode),
    TradingDataInvalidContentTypeException(:final contentType) =>
      TradingInvalidContentTypeFailure(contentType: contentType),
    TradingDataIdleTimeoutException() => const TradingIdleTimeoutFailure(),
    TradingDataParseException() => const TradingDataParseFailure(),
    TradingDataUnknownException(:final error) =>
      TradingUnknownFailure(error: error),
  };
}
