import 'package:flutter/material.dart';

import '../../domain/entities/market.dart';

class MarketTile extends StatelessWidget {
  final MarketEntity market;
  final bool selected;
  final VoidCallback onTap;

  const MarketTile({
    super.key,
    required this.market,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 92,
          maxWidth: 132,
        ),
        child: ChoiceChip(
          selected: selected,
          onSelected: (_) => onTap(),
          label: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                market.symbol,
                style: theme.textTheme.labelLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (market.lastPrice != null)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _formatMarketPrice(market.lastPrice!),
                    style: theme.textTheme.labelSmall,
                    maxLines: 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatMarketPrice(double value) {
  if (value.isNaN || value.isInfinite) {
    return value.toString();
  }

  final fixed = value.abs() >= 1000000000
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);

  return fixed
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
