import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:sarmayex/features/data/datasources/trading_sse_remote_datasource.dart';
import 'package:sarmayex/features/domain/repositories/trading_repository.dart';

import '../../features/data/repositories/trading_repository_impl.dart';
import '../../features/domain/usecases/watch_trading_use_case.dart';
import '../network/sse/client/sse_client.dart';
import '../network/sse/client/sse_client_impl.dart';
import '../network/sse/connection/http_sse_connection.dart';
import '../network/sse/connection/sse_connection.dart';
import '../network/sse/connection/sse_response_validator.dart';
import '../network/sse/parser/sse_parser.dart';
import '../network/sse/parser/sse_parser_impl.dart';
import '../network/sse/retry/exponential_backoff_retry_policy.dart';
import '../network/sse/retry/sse_retry_policy.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await initSseDependencies();
  await initTradingDependencies();
}

Future<void> initSseDependencies() async {
  sl.registerLazySingleton<HttpClient>(
    () => HttpClient(),
  );

  sl.registerLazySingleton<SseResponseValidator>(
    () => const SseResponseValidator(),
  );

  sl.registerFactory<SseParser>(
    () => SseParserImpl(),
  );

  sl.registerLazySingleton<SseConnection>(
    () => HttpSseConnection(
      httpClient: sl<HttpClient>(),
      validator: sl<SseResponseValidator>(),
    ),
  );

  sl.registerLazySingleton<SseRetryPolicy>(
    () => ExponentialBackoffRetryPolicy(),
  );

  sl.registerLazySingleton<SseClient>(
    () => SseClientImpl(
      connection: sl<SseConnection>(),
      parserFactory: () => sl<SseParser>(),
      retryPolicy: sl<SseRetryPolicy>(),
    ),
  );
}

Future<void> initTradingDependencies() async {
  sl.registerLazySingleton<TradingSseRemoteDatasource>(
    () => TradingSseRemoteDatasourceImpl(
      sseClient: sl<SseClient>(),
    ),
  );

  sl.registerLazySingleton<TradingRepository>(
    () => TradingRepositoryImpl(
      remoteDatasource: sl<TradingSseRemoteDatasource>(),
    ),
  );

  sl.registerLazySingleton<WatchTradingUseCase>(
    () => WatchTradingUseCase(sl<TradingRepository>()),
  );
}
