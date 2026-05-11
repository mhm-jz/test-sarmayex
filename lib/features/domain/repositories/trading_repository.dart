import 'package:sarmayex/features/domain/failures/trading_failure.dart';

import '../../../core/result/result.dart';
import '../entities/trading_realtime_entity.dart';

abstract interface class TradingRepository {
  Stream<Result<TradingRealtimeEntity, TradingFailure>> watchTrading({
    required String market,
  });
}
