import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/result/result.dart';
import '../../../domain/entities/order_book.dart';
import '../../../domain/entities/trading_realtime_entity.dart';
import '../../../domain/usecases/watch_trading_use_case.dart';
import 'trading_event.dart';
import 'trading_state.dart';

final class TradingBloc extends Bloc<TradingEvent, TradingState> {
  final WatchTradingUseCase _watchTrading;

  StreamSubscription? _subscription;
  Timer? _emitTimer;
  Timer? _firstOrderBookTimer;

  OrderBook? _pendingOrderBook;
  int _generation = 0;

  bool _isStale(int generation) {
    return isClosed || generation != _generation;
  }

  TradingBloc({
    required WatchTradingUseCase watchTrading,
  })  : _watchTrading = watchTrading,
        super(TradingState.initial()) {
    on<TradingStarted>(_onStarted);
    on<TradingMarketSelected>(_onMarketSelected);
    on<TradingRetryRequested>(_onRetryRequested);

    on<TradingRealtimeReceived>(_onRealtimeReceived);
    on<TradingRealtimeFailed>(_onRealtimeFailed);
    on<TradingFirstOrderBookTimeout>(_onFirstOrderBookTimeout);
    on<TradingEmitPendingOrderBook>(_onEmitPendingOrderBook);
  }

  Future<void> _onStarted(
    TradingStarted event,
    Emitter<TradingState> emit,
  ) async {
    await _subscribe(
      market: event.initialMarket,
      emit: emit,
      clearOrderBook: true,
    );
  }

  Future<void> _onMarketSelected(
    TradingMarketSelected event,
    Emitter<TradingState> emit,
  ) async {
    if (state.selectedMarket == event.market &&
        state.status == TradingConnectionStatus.connected) {
      return;
    }

    await _subscribe(
      market: event.market,
      emit: emit,
      clearOrderBook: true,
    );
  }

  Future<void> _onRetryRequested(
    TradingRetryRequested event,
    Emitter<TradingState> emit,
  ) async {
    await _subscribe(
      market: state.selectedMarket,
      emit: emit,
      clearOrderBook: false,
    );
  }

  Future<void> _subscribe({
    required String market,
    required Emitter<TradingState> emit,
    required bool clearOrderBook,
  }) async {
    final currentGeneration = ++_generation;
    _emitTimer?.cancel();
    _firstOrderBookTimer?.cancel();
    _pendingOrderBook = null;
    await _subscription?.cancel();

    emit(
      state.copyWith(
        selectedMarket: market,
        status: state.bids.isEmpty || clearOrderBook
            ? TradingConnectionStatus.connecting
            : TradingConnectionStatus.reconnecting,
        clearFailure: true,
        clearOrderBook: clearOrderBook,
      ),
    );
    _startFirstOrderBookTimer(
      market: market,
      generation: currentGeneration,
    );

    _subscription = _watchTrading(market: market).listen(
      (result) {
        if (_isStale(currentGeneration)) {
          return;
        }

        switch (result) {
          case Success(:final data):
            add(
              TradingRealtimeReceived(
                generation: currentGeneration,
                event: data,
              ),
            );

          case FailureResult(:final error):
            add(
              TradingRealtimeFailed(
                generation: currentGeneration,
                failure: error,
              ),
            );
        }
      },
    );
  }

  void _onRealtimeReceived(
    TradingRealtimeReceived event,
    Emitter<TradingState> emit,
  ) {
    if (_isStale(event.generation)) {
      return;
    }

    switch (event.event) {
      case MarketsRealtimeEntity(:final markets):
        emit(
          state.copyWith(
            markets: markets,
            status: TradingConnectionStatus.connected,
            clearFailure: true,
          ),
        );

      case OrderBookRealtimeEntity(:final orderBook):
        _firstOrderBookTimer?.cancel();
        _firstOrderBookTimer = null;
        _scheduleOrderBookEmit(
          orderBook: orderBook,
          generation: event.generation,
        );
    }
  }

  void _onRealtimeFailed(
    TradingRealtimeFailed event,
    Emitter<TradingState> emit,
  ) {
    if (_isStale(event.generation)) {
      return;
    }
    emit(
      state.copyWith(
        status: state.bids.isEmpty
            ? TradingConnectionStatus.failure
            : TradingConnectionStatus.reconnecting,
        failure: event.failure,
      ),
    );
  }

  void _onFirstOrderBookTimeout(
    TradingFirstOrderBookTimeout event,
    Emitter<TradingState> emit,
  ) {
    if (_isStale(event.generation)) {
      return;
    }

    if (state.bids.isNotEmpty || state.asks.isNotEmpty) {
      return;
    }

    emit(
      state.copyWith(
        status: TradingConnectionStatus.connecting,
        clearFailure: true,
      ),
    );
  }

  void _scheduleOrderBookEmit({
    required OrderBook orderBook,
    required int generation,
  }) {
    _pendingOrderBook = orderBook;

    if (_emitTimer?.isActive ?? false) {
      return;
    }

    _emitTimer = Timer(const Duration(milliseconds: 40), () {
      if (_isStale(generation)) {
        return;
      }

      add(
        TradingEmitPendingOrderBook(
          generation: generation,
        ),
      );
    });
  }

  void _onEmitPendingOrderBook(
    TradingEmitPendingOrderBook event,
    Emitter<TradingState> emit,
  ) {
    if (_isStale(event.generation)) {
      return;
    }

    final latest = _pendingOrderBook;

    if (latest == null) {
      return;
    }
    emit(
      state.copyWith(
        selectedMarket: latest.market,
        status: TradingConnectionStatus.connected,
        bids: latest.bids,
        asks: latest.asks,
        clearFailure: true,
      ),
    );

    _pendingOrderBook = null;
  }

  void _startFirstOrderBookTimer({
    required String market,
    required int generation,
  }) {
    _firstOrderBookTimer?.cancel();

    _firstOrderBookTimer = Timer(const Duration(seconds: 30), () {
      if (_isStale(generation)) {
        return;
      }

      add(
        TradingFirstOrderBookTimeout(
          generation: generation,
          market: market,
        ),
      );
    });
  }

  @override
  Future<void> close() async {
    _generation++;
    _emitTimer?.cancel();
    _firstOrderBookTimer?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
