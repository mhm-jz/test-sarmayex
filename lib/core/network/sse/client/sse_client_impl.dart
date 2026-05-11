import 'dart:async';
import 'dart:developer' as developer;

import 'package:sarmayex/core/network/sse/sse_event.dart';

import '../connection/sse_connection.dart';
import '../parser/sse_parser.dart';
import '../retry/sse_retry_policy.dart';
import 'sse_client.dart';

class SseClientImpl implements SseClient {
  final SseConnection _connection;
  final SseParser Function() _parserFactory;
  final SseRetryPolicy _retryPolicy;

  SseClientImpl({
    required SseConnection connection,
    required SseParser Function() parserFactory,
    required SseRetryPolicy retryPolicy,
  })  : _connection = connection,
        _parserFactory = parserFactory,
        _retryPolicy = retryPolicy;

  @override
  Stream<SseEvent> connect(
    Uri uri, {
    Map<String, String> headers = const {},
    Duration connectionTimeout = const Duration(seconds: 45),
    Duration idleTimeout = const Duration(seconds: 45),
    bool reconnect = true,
  }) {
    late StreamController<SseEvent> controller;

    var cancelled = false;
    var generation = 0;
    var retryAttempt = 0;
    String? lastEventId;
    StreamSubscription<String>? activeLineSubscription;
    Completer<bool>? activeConnectionCompleter;

    Future<void> reconnectDelay() async {
      final delay = _retryPolicy.delayForAttempt(retryAttempt);
      _sseLog('retry uri=$uri attempt=$retryAttempt delay=$delay');

      retryAttempt++;
      await Future.delayed(delay);
    }

    Map<String, String> buildHeaders() {
      final result = Map<String, String>.from(headers);

      if (lastEventId != null && lastEventId!.isNotEmpty) {
        result['Last-Event-ID'] = lastEventId!;
      }

      return result;
    }

    Future<bool> consumeConnection(int currentGeneration) async {
      final parser = _parserFactory();

      var emittedAtLeastOneEvent = false;
      final completer = Completer<bool>();
      activeConnectionCompleter = completer;

      void complete(bool value) {
        if (!completer.isCompleted) {
          completer.complete(value);
        }
      }

      void completeError(Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      }

      late final StreamSubscription<String> lineSubscription;

      lineSubscription = _connection
          .connect(
            uri,
            headers: buildHeaders(),
            connectionTimeout: connectionTimeout,
            idleTimeout: idleTimeout,
          )
          .listen(
            (line) async {
              if (cancelled || currentGeneration != generation) {
                await lineSubscription.cancel();
                complete(false);
                return;
              }

              final event = parser.parseLine(line);

              if (event == null || !event.hasData) {
                return;
              }

              if (event.id != null && event.id!.isNotEmpty) {
                lastEventId = event.id;
              }

              emittedAtLeastOneEvent = true;
              retryAttempt = 0;
              if (!controller.isClosed) {
                controller.add(event);
              }
            },
            onError: completeError,
            onDone: () {
              final lastEvent = parser.close();

              if (lastEvent != null &&
                  lastEvent.hasData &&
                  !controller.isClosed &&
                  !cancelled) {
                if (lastEvent.id != null && lastEvent.id!.isNotEmpty) {
                  lastEventId = lastEvent.id;
                }

                emittedAtLeastOneEvent = true;
                retryAttempt = 0;

                controller.add(lastEvent);
              }

              complete(emittedAtLeastOneEvent);
            },
            cancelOnError: true,
          );

      activeLineSubscription = lineSubscription;

      try {
        return await completer.future;
      } finally {
        if (identical(activeLineSubscription, lineSubscription)) {
          activeLineSubscription = null;
        }
        if (identical(activeConnectionCompleter, completer)) {
          activeConnectionCompleter = null;
        }
      }
    }

    Future<void> start() async {
      final currentGeneration = ++generation;
      while (!cancelled && currentGeneration == generation) {
        try {
          await consumeConnection(currentGeneration);

          if (cancelled || currentGeneration != generation) {
            return;
          }

          if (!reconnect ||
              !_retryPolicy.shouldRetryAfterNormalClose(retryAttempt)) {
            if (!controller.isClosed) {
              await controller.close();
            }
            return;
          }
          await reconnectDelay();
        } catch (error, stackTrace) {
          if (cancelled || currentGeneration != generation) {
            return;
          }

          _sseLog('error uri=$uri attempt=$retryAttempt error=$error');

          if (!reconnect ||
              !_retryPolicy.shouldRetryError(error, retryAttempt)) {
            if (!controller.isClosed) {
              controller.addError(error, stackTrace);
              await controller.close();
            }
            return;
          }

          if (!controller.isClosed) {
            controller.addError(error, stackTrace);
          }

          await reconnectDelay();
        }
      }
    }

    controller = StreamController<SseEvent>(
      onListen: start,
      onCancel: () async {
        cancelled = true;
        generation++;
        if (!(activeConnectionCompleter?.isCompleted ?? true)) {
          activeConnectionCompleter?.complete(false);
        }
        await activeLineSubscription?.cancel();
        activeLineSubscription = null;
      },
    );

    return controller.stream;
  }
}

void _sseLog(String message) {
  developer.log(message, name: 'SSE_CLIENT');
}
