import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order_book_item_entity.dart';
import '../bloc/trading/trading_bloc.dart';
import '../bloc/trading/trading_state.dart';
import 'order_book_side.dart';

class OrderBookRowSelector extends StatelessWidget {
  final OrderBookSideType side;
  final int index;

  const OrderBookRowSelector({
    super.key,
    required this.side,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TradingBloc, TradingState, OrderBookItemEntity?>(
      selector: (state) {
        final entries = switch (side) {
          OrderBookSideType.bids => state.bids,
          OrderBookSideType.asks => state.asks,
        };

        if (index >= entries.length) {
          return null;
        }

        return entries[index];
      },
      builder: (context, entry) {
        if (entry == null) {
          return const SizedBox.shrink();
        }

        return OrderBookRow(
          entry: entry,
        );
      },
    );
  }
}

class OrderBookRow extends StatelessWidget {
  final OrderBookItemEntity entry;

  const OrderBookRow({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        child: Row(
          children: [
            Expanded(
              child: _ResponsiveNumberText(
                value: entry.price,
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ResponsiveNumberText(
                value: entry.amount,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponsiveNumberText extends StatelessWidget {
  final double value;
  final TextAlign textAlign;

  const _ResponsiveNumberText({
    required this.value,
    required this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final text = _formatNumber(value);
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: textAlign == TextAlign.end
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: textAlign == TextAlign.end
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Text(
                text,
                style: style,
                textAlign: textAlign,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }
}

String _formatNumber(double value) {
  if (value.isNaN || value.isInfinite) {
    return value.toString();
  }

  final absolute = value.abs();
  final fractionDigits = switch (absolute) {
    >= 1000000000 => 0,
    >= 1 => 6,
    _ => 8,
  };

  final fixed = value.toStringAsFixed(fractionDigits);
  if (!fixed.contains('.')) {
    return fixed;
  }

  return fixed
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
