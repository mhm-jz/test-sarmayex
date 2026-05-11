import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/watch_trading_use_case.dart';
import '../bloc/trading/trading_bloc.dart';
import '../bloc/trading/trading_event.dart';
import '../widgets/markets_widget.dart';
import '../widgets/order_book_widget.dart';

class TradingPage extends StatelessWidget {
  const TradingPage({super.key});

  @override
  Widget build(BuildContext context) {
    const initialMarket = 'USDT_IRT';
    return BlocProvider(
      create: (_) {
        return TradingBloc(
          watchTrading: sl<WatchTradingUseCase>(),
        )..add(
            const TradingStarted(
              initialMarket: initialMarket,
            ),
          );
      },
      child: const _TradingView(),
    );
  }
}

class _TradingView extends StatelessWidget {
  const _TradingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _TradingAppBar(),
      body: Column(
        children: [
          SizedBox(
            height: 96,
            child: MarketsWidget(),
          ),
          Expanded(
            child: OrderBookWidget(),
          ),
        ],
      ),
    );
  }
}

class _TradingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _TradingAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Live Markets'),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
