import '../../domain/failures/trading_failure.dart';

extension TradingFailureMessageMapper on TradingFailure {
  String toMessage() {
    return switch (this) {
      TradingNetworkFailure() => 'Network connection failed.',
      TradingUnauthorizedFailure() => 'You are not authorized.',
      TradingInvalidMarketFailure(:final market) => market == null
          ? 'Selected market is not available.'
          : '$market is not available.',
      TradingServerFailure() => 'Server error. Please try again.',
      TradingInvalidContentTypeFailure() => 'Invalid server response.',
      TradingIdleTimeoutFailure() => 'Connection timed out.',
      TradingDataParseFailure() => 'Could not read market data.',
      TradingUnknownFailure() => 'Unexpected error occurred.',
    };
  }
}
