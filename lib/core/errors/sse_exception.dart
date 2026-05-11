import 'package:sarmayex/core/errors/exceptions.dart';

sealed class SseException extends AppException {
  const SseException();
}

class SseNetworkException extends SseException {
  final Object error;

  const SseNetworkException(this.error);
}

class SseUnauthorizedException extends SseException {
  const SseUnauthorizedException();
}

class SseInvalidMarketException extends SseException {
  final String? market;

  const SseInvalidMarketException([this.market]);
}

class SseServerException extends SseException {
  final int statusCode;

  const SseServerException(this.statusCode);
}

class SseInvalidContentTypeException extends SseException {
  final String? contentType;

  const SseInvalidContentTypeException(this.contentType);
}

class SseIdleTimeoutException extends SseException {
  final Duration timeout;

  const SseIdleTimeoutException(this.timeout);
}

class SseDataParseException extends SseException {
  final String? event;
  final String rawData;

  const SseDataParseException({
    required this.event,
    required this.rawData,
  });
}

class SseCancelledException extends SseException {
  const SseCancelledException();
}
