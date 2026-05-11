import 'package:sarmayex/core/network/sse/sse_event.dart';

abstract interface class SseParser {
  SseEvent? parseLine(String line);

  SseEvent? close();
}
