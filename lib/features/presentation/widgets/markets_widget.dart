import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sarmayex/features/presentation/mapper/trading_failure_message_mapper.dart';

import '../../domain/entities/market.dart';
import '../bloc/trading/trading_bloc.dart';
import '../bloc/trading/trading_event.dart';
import '../bloc/trading/trading_state.dart';
import 'market_tile.dart';

class MarketsWidget extends StatelessWidget {
  const MarketsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TradingBloc, TradingState, _MarketsViewModel>(
      selector: (state) {
        final errorMessage =
            state.markets.isEmpty ? state.failure?.toMessage() : null;

        return _MarketsViewModel(
          markets: state.markets,
          selectedMarket: state.selectedMarket,
          isLoading: state.markets.isEmpty && errorMessage == null,
          errorMessage: errorMessage,
        );
      },
      builder: (context, viewModel) {
        if (viewModel.isLoading && viewModel.markets.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (viewModel.errorMessage != null && viewModel.markets.isEmpty) {
          return Center(
            child: Text(viewModel.errorMessage!),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: viewModel.markets.length,
          itemBuilder: (context, index) {
            final market = viewModel.markets[index];

            return MarketTile(
              market: market,
              selected: market.symbol == viewModel.selectedMarket,
              onTap: () {
                context.read<TradingBloc>().add(
                      TradingMarketSelected(
                        market: market.symbol,
                      ),
                    );
              },
            );
          },
        );
      },
    );
  }
}

final class _MarketsViewModel extends Equatable {
  final List<MarketEntity> markets;
  final String selectedMarket;
  final bool isLoading;
  final String? errorMessage;

  const _MarketsViewModel({
    required this.markets,
    required this.selectedMarket,
    required this.isLoading,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [
        markets,
        selectedMarket,
        isLoading,
        errorMessage,
      ];
}
