import 'package:sarmayex/core/result/result.dart';
import 'package:sarmayex/features/data/datasources/trading_sse_remote_datasource.dart';
import 'package:sarmayex/features/data/mapper/trading_failure_mapper.dart';
import 'package:sarmayex/features/data/mapper/trading_realtime_mapper.dart';
import 'package:sarmayex/features/domain/failures/trading_failure.dart';
import 'package:sarmayex/features/domain/repositories/trading_repository.dart';

import '../../domain/entities/trading_realtime_entity.dart';

final class TradingRepositoryImpl implements TradingRepository {
  final TradingSseRemoteDatasource _remoteDatasource;

  const TradingRepositoryImpl({
    required TradingSseRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  @override
  Stream<Result<TradingRealtimeEntity, TradingFailure>> watchTrading({
    required String market,
  }) {
    return _remoteDatasource.watchTrading(market: market).map((result) {
      return switch (result) {
        Success(:final data) => Success(data.toEntity()),
        FailureResult(:final error) => FailureResult(
            mapDataExceptionToTradingFailure(error),
          ),
      };
    });
  }
}
