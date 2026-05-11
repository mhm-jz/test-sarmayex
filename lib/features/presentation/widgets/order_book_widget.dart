import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sarmayex/features/presentation/mapper/trading_failure_message_mapper.dart';

import '../bloc/trading/trading_bloc.dart';
import '../bloc/trading/trading_event.dart';
import '../bloc/trading/trading_state.dart';
import 'order_book_side.dart';
import 'realtime_status_banner.dart';

class OrderBookWidget extends StatelessWidget {
  const OrderBookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _OrderBookStatusSection(),
        _OrderBookContent(),
      ],
    );
  }
}

class _OrderBookContent extends StatelessWidget {
  const _OrderBookContent();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TradingBloc, TradingState, _OrderBookContentViewModel>(
      selector: (state) {
        return _OrderBookContentViewModel(
          hasOrderBook: state.bids.isNotEmpty || state.asks.isNotEmpty,
          isLoading: _isOrderBookLoading(state),
        );
      },
      builder: (context, viewModel) {
        if (!viewModel.hasOrderBook && !viewModel.isLoading) {
          return const SizedBox.shrink();
        }

        return const Expanded(
          child: Column(
            children: [
              _OrderBookHeader(),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _BidsSection(),
                    ),
                    VerticalDivider(width: 1),
                    Expanded(
                      child: _AsksSection(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrderBookStatusSection extends StatelessWidget {
  const _OrderBookStatusSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TradingBloc, TradingState, _StatusViewModel>(
      selector: (state) {
        return _StatusViewModel(
          status: state.status,
          message: state.failure?.toMessage(),
        );
      },
      builder: (context, viewModel) {
        return RealtimeStatusBanner(
          status: viewModel.status,
          message: viewModel.message,
          onRetry: () {
            context.read<TradingBloc>().add(
                  const TradingRetryRequested(),
                );
          },
        );
      },
    );
  }
}

class _OrderBookHeader extends StatelessWidget {
  const _OrderBookHeader();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TradingBloc, TradingState, _HeaderViewModel>(
      selector: (state) {
        return _HeaderViewModel(
          market: state.selectedMarket,
        );
      },
      builder: (context, viewModel) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            'Order Book: ${viewModel.market}',
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}

class _BidsSection extends StatelessWidget {
  const _BidsSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TradingBloc, TradingState, _BookSideStructureViewModel>(
      selector: (state) {
        return _BookSideStructureViewModel(
          count: state.bids.length,
          isLoading: _isOrderBookLoading(state),
        );
      },
      builder: (context, viewModel) {
        return OrderBookSide(
          title: 'Bids',
          side: OrderBookSideType.bids,
          count: viewModel.count,
          isLoading: viewModel.isLoading,
        );
      },
    );
  }
}

class _AsksSection extends StatelessWidget {
  const _AsksSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TradingBloc, TradingState, _BookSideStructureViewModel>(
      selector: (state) {
        return _BookSideStructureViewModel(
          count: state.asks.length,
          isLoading: _isOrderBookLoading(state),
        );
      },
      builder: (context, viewModel) {
        return OrderBookSide(
          title: 'Asks',
          side: OrderBookSideType.asks,
          count: viewModel.count,
          isLoading: viewModel.isLoading,
        );
      },
    );
  }
}

final class _HeaderViewModel extends Equatable {
  final String market;

  const _HeaderViewModel({
    required this.market,
  });

  @override
  List<Object?> get props => [market];
}

final class _OrderBookContentViewModel extends Equatable {
  final bool hasOrderBook;
  final bool isLoading;

  const _OrderBookContentViewModel({
    required this.hasOrderBook,
    required this.isLoading,
  });

  @override
  List<Object?> get props => [hasOrderBook, isLoading];
}

final class _StatusViewModel extends Equatable {
  final TradingConnectionStatus status;
  final String? message;

  const _StatusViewModel({
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => [status, message];
}

final class _BookSideStructureViewModel extends Equatable {
  final int count;
  final bool isLoading;

  const _BookSideStructureViewModel({
    required this.count,
    required this.isLoading,
  });

  @override
  List<Object?> get props => [count, isLoading];
}

bool _isOrderBookLoading(TradingState state) {
  return state.status == TradingConnectionStatus.initial ||
      state.status == TradingConnectionStatus.connecting;
}
