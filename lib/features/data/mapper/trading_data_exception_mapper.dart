import 'dart:async';
import 'dart:io';

import 'package:sarmayex/features/data/exception/trading_data_exception.dart';

import '../../../core/errors/sse_exception.dart';

TradingDataException mapToTradingDataException(
  Object error, {
  String? selectedMarket,
}) {
  return switch (error) {
    SocketException() => const TradingDataNetworkException(),
    HttpException() => const TradingDataNetworkException(),
    TimeoutException() => const TradingDataIdleTimeoutException(),
    SseNetworkException() => const TradingDataNetworkException(),
    SseUnauthorizedException() => const TradingDataUnauthorizedException(),
    SseInvalidMarketException(market: final errorMarket) =>
      TradingDataInvalidMarketException(
        market: errorMarket ?? selectedMarket,
      ),
    SseServerException(:final statusCode) => TradingDataServerException(
        statusCode: statusCode,
      ),
    SseInvalidContentTypeException(:final contentType) =>
      TradingDataInvalidContentTypeException(
        contentType: contentType,
      ),
    SseIdleTimeoutException() => const TradingDataIdleTimeoutException(),
    SseDataParseException(:final event, :final rawData) =>
      TradingDataParseException(
        event: event,
        rawData: rawData,
      ),
    _ => TradingDataUnknownException(error: error),
  };
}
