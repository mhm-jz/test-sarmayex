import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sarmayex/core/errors/sse_exception.dart';

import 'sse_connection.dart';
import 'sse_response_validator.dart';

class HttpSseConnection implements SseConnection {
  final HttpClient _httpClient;
  final SseResponseValidator _validator;
  var cancelledByUser = false;

  HttpSseConnection({
    required HttpClient httpClient,
    required SseResponseValidator validator,
  })  : _httpClient = httpClient,
        _validator = validator;

  @override
  Stream<String> connect(
    Uri uri, {
    Map<String, String> headers = const {},
    Duration connectionTimeout = const Duration(seconds: 45),
    Duration idleTimeout = const Duration(seconds: 45),
  }) {
    late StreamController<String> controller;

    HttpClientRequest? request;
    StreamSubscription<String>? subscription;
    Timer? idleTimer;

    void resetIdleTimer() {
      idleTimer?.cancel();

      idleTimer = Timer(idleTimeout, () async {
        await subscription?.cancel();

        try {
          request?.abort();
        } catch (_) {}

        if (!controller.isClosed) {
          controller.addError(
            SseIdleTimeoutException(idleTimeout),
          );
          await controller.close();
        }
      });
    }

    Future<void> cleanup() async {
      idleTimer?.cancel();
      idleTimer = null;

      try {
        await subscription?.cancel();
      } catch (_) {}

      subscription = null;

      try {
        request?.abort();
      } catch (_) {}

      request = null;
    }

    controller = StreamController<String>(
      onListen: () async {
        try {
          request = await _httpClient.getUrl(uri).timeout(connectionTimeout);

          request!.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
          request!.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');

          for (final header in headers.entries) {
            request!.headers.set(header.key, header.value);
          }
          final response = await request!.close().timeout(connectionTimeout);

          _validator.validate(response);

          resetIdleTimer();

          final lineStream =
              response.transform(utf8.decoder).transform(const LineSplitter());

          subscription = lineStream.listen(
            (line) {
              resetIdleTimer();
              if (!controller.isClosed) {
                controller.add(line);
              }
            },
            onError: (Object error, StackTrace stackTrace) async {
              await cleanup();

              if (!controller.isClosed) {
                controller.addError(error, stackTrace);
                await controller.close();
              }
            },
            onDone: () async {
              await cleanup();

              if (!controller.isClosed) {
                await controller.close();
              }
            },
            cancelOnError: true,
          );
        } catch (error, stackTrace) {
          await cleanup();

          if (!controller.isClosed) {
            controller.addError(error, stackTrace);
            await controller.close();
          }
        }
      },
      onCancel: () async {
        cancelledByUser = true;
        await cleanup();
      },
    );

    return controller.stream;
  }

  void dispose() {
    _httpClient.close(force: true);
  }
}
