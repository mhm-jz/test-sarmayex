import 'package:sarmayex/core/network/sse/sse_event.dart';

abstract interface class SseClient {
  Stream<SseEvent> connect(
    Uri uri, {
    Map<String, String> headers,
    Duration connectionTimeout,
    Duration idleTimeout,
    bool reconnect,
  });
}
