import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:sarmayex/core/errors/sse_exception.dart';

import 'sse_retry_policy.dart';

class ExponentialBackoffRetryPolicy implements SseRetryPolicy {
  final int maxAttempts;
  final Duration maxDelay;
  final Random _random;

  ExponentialBackoffRetryPolicy({
    this.maxAttempts = 20,
    this.maxDelay = const Duration(seconds: 10),
    Random? random,
  }) : _random = random ?? Random();

  @override
  bool shouldRetryError(Object error, int attempt) {
    if (attempt >= maxAttempts) {
      return false;
    }

    if (error is SseCancelledException) {
      return false;
    }

    if (error is SseUnauthorizedException) {
      return false;
    }

    if (error is SseInvalidMarketException) {
      return false;
    }

    if (error is SseInvalidContentTypeException) {
      return false;
    }

    if (error is SseServerException) {
      return error.statusCode >= 500;
    }

    if (error is SocketException) {
      return true;
    }

    if (error is TimeoutException) {
      return true;
    }
    if (error is SseIdleTimeoutException) {
      return true;
    }

    if (error is SseNetworkException) {
      return true;
    }

    return true;
  }

  @override
  bool shouldRetryAfterNormalClose(int attempt) {
    return attempt < maxAttempts;
  }

  @override
  Duration delayForAttempt(int attempt) {
    final seconds = switch (attempt) {
      0 => 1,
      1 => 2,
      2 => 4,
      3 => 8,
      _ => maxDelay.inSeconds,
    };


    final jitterMs = _random.nextInt(500);

    final delay = Duration(
      seconds: seconds,
      milliseconds: jitterMs,
    );

    return delay > maxDelay ? maxDelay : delay;
  }
}
