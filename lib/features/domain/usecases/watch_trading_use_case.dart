
import '../../../../core/result/result.dart';
import '../entities/trading_realtime_entity.dart';
import '../failures/trading_failure.dart';
import '../repositories/trading_repository.dart';

final class WatchTradingUseCase {
  final TradingRepository _repository;

  const WatchTradingUseCase(this._repository);

  Stream<Result<TradingRealtimeEntity, TradingFailure>> call({
    required String market,
  }) {
    return _repository.watchTrading(market: market);
  }
}
