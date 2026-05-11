import 'dart:async';
import 'dart:convert';

import 'package:sarmayex/core/network/sse/sse_event.dart';
import 'package:sarmayex/features/data/exception/trading_data_exception.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/sse/client/sse_client.dart';
import '../../../../core/result/result.dart';
import '../mapper/trading_data_exception_mapper.dart';
import '../models/market_model.dart';
import '../models/order_book_model.dart';
import '../models/sse_trading_envelope_model.dart';
import '../models/trading_realtime_model.dart';

abstract interface class TradingSseRemoteDatasource {
  Stream<Result<TradingRealtimeModel, TradingDataException>> watchTrading({
    required String market,
  });
}

final class TradingSseRemoteDatasourceImpl
    implements TradingSseRemoteDatasource {
  final SseClient _sseClient;

  const TradingSseRemoteDatasourceImpl({
    required SseClient sseClient,
  }) : _sseClient = sseClient;

  @override
  Stream<Result<TradingRealtimeModel, TradingDataException>> watchTrading({
    required String market,
  }) {
    final uri = ApiConstants.marketSubscribeUri(market);

    return _mapTradingStream(
      stream: _sseClient.connect(uri),
      market: market,
    );
  }

  Stream<Result<TradingRealtimeModel, TradingDataException>> _mapTradingStream({
    required Stream<SseEvent> stream,
    required String market,
  }) {
    late StreamController<Result<TradingRealtimeModel, TradingDataException>>
        controller;

    StreamSubscription<SseEvent>? subscription;

    controller =
        StreamController<Result<TradingRealtimeModel, TradingDataException>>(
      onListen: () {
        subscription = stream.listen(
          (sseEvent) {
            String? envelopeEvent;

            try {
              final decoded = jsonDecode(sseEvent.data);

              if (decoded is! Map<String, dynamic>) {
                throw FormatException(
                  'Invalid SSE JSON envelope: ${sseEvent.data}',
                );
              }

              envelopeEvent = decoded['event']?.toString();

              final envelope = SseTradingEnvelopeModel.fromJson(decoded);

              switch (envelope.event) {
                case 'markets':
                  final markets = _parseMarkets(envelope.data);

                  controller.add(
                    Success(
                      MarketsRealtimeModel(
                        markets: markets,
                      ),
                    ),
                  );

                case 'order_book':
                  final orderBook = OrderBookModel.fromJson(
                    market: market,
                    json: envelope.data,
                  );

                  controller.add(
                    Success(
                      OrderBookRealtimeModel(
                        orderBook: orderBook,
                      ),
                    ),
                  );

                default:
                  return;
              }
            } catch (error) {
              controller.add(
                FailureResult(
                  TradingDataParseException(
                    event: envelopeEvent,
                    rawData: sseEvent.data,
                  ),
                ),
              );
            }
          },
          onError: (Object error) {
            controller.add(
              FailureResult(
                mapToTradingDataException(
                  error,
                  selectedMarket: market,
                ),
              ),
            );
          },
          onDone: controller.close,
          cancelOnError: false,
        );
      },
      onCancel: () async {
        await subscription?.cancel();
      },
    );

    return controller.stream;
  }

  List<MarketModel> _parseMarkets(Map<String, dynamic> data) {
    final rawChanges = data['changes'];

    if (rawChanges is! Map<String, dynamic>) {
      throw FormatException('Invalid markets changes payload: $data');
    }

    return rawChanges.entries
        .where((entry) => entry.value is Map<String, dynamic>)
        .map(
          (entry) => MarketModel.fromSymbolChange(
            symbol: entry.key,
            json: entry.value as Map<String, dynamic>,
          ),
        )
        .toList(growable: false);
  }
}
