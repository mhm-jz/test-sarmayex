abstract interface class SseRetryPolicy {
  bool shouldRetryError(Object error, int attempt);

  bool shouldRetryAfterNormalClose(int attempt);

  Duration delayForAttempt(int attempt);
}
