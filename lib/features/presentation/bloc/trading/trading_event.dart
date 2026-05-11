import 'package:equatable/equatable.dart';
import 'package:sarmayex/features/domain/entities/trading_realtime_entity.dart';

import '../../../domain/failures/trading_failure.dart';

sealed class TradingEvent extends Equatable {
  const TradingEvent();
}

final class TradingStarted extends TradingEvent {
  final String initialMarket;

  const TradingStarted({
    required this.initialMarket,
  });

  @override
  List<Object?> get props => [initialMarket];
}

final class TradingMarketSelected extends TradingEvent {
  final String market;

  const TradingMarketSelected({
    required this.market,
  });

  @override
  List<Object?> get props => [market];
}

final class TradingRetryRequested extends TradingEvent {
  const TradingRetryRequested();

  @override
  List<Object?> get props => [];
}

final class TradingRealtimeReceived extends TradingEvent {
  final int generation;
  final TradingRealtimeEntity event;

  const TradingRealtimeReceived({
    required this.generation,
    required this.event,
  });

  @override
  List<Object?> get props => [generation, event];
}

final class TradingRealtimeFailed extends TradingEvent {
  final int generation;
  final TradingFailure failure;

  const TradingRealtimeFailed({
    required this.generation,
    required this.failure,
  });

  @override
  List<Object?> get props => [generation, failure];
}

final class TradingFirstOrderBookTimeout extends TradingEvent {
  final int generation;
  final String market;

  const TradingFirstOrderBookTimeout({
    required this.generation,
    required this.market,
  });

  @override
  List<Object?> get props => [generation, market];
}

final class TradingEmitPendingOrderBook extends TradingEvent {
  final int generation;

  const TradingEmitPendingOrderBook({
    required this.generation,
  });

  @override
  List<Object?> get props => [generation];
}
