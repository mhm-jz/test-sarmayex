abstract interface class SseConnection {
  Stream<String> connect(
    Uri uri, {
    Map<String, String> headers,
    Duration connectionTimeout,
    Duration idleTimeout,
  });
}
