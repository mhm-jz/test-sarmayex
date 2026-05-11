import 'package:flutter/material.dart';

import 'order_book_row.dart';

enum OrderBookSideType {
  asks,
  bids,
}

class OrderBookSide extends StatelessWidget {
  final String title;
  final OrderBookSideType side;
  final int count;
  final bool isLoading;

  const OrderBookSide({
    super.key,
    required this.title,
    required this.side,
    required this.count,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _OrderBookSideTitle(title: title),
        const _OrderBookColumnHeader(),
        Expanded(
          child: isLoading && count == 0
              ? const _OrderBookSidePlaceholder()
              : ListView.builder(
                  itemCount: count,
                  itemBuilder: (context, index) {
                    return OrderBookRowSelector(
                      side: side,
                      index: index,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _OrderBookSideTitle extends StatelessWidget {
  final String title;

  const _OrderBookSideTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _OrderBookColumnHeader extends StatelessWidget {
  const _OrderBookColumnHeader();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Price',
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Amount',
              style: style,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderBookSidePlaceholder extends StatelessWidget {
  const _OrderBookSidePlaceholder();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          child: Row(
            children: [
              Expanded(
                child: _PlaceholderBar(
                  color: color,
                  alignment: Alignment.centerLeft,
                  widthFactor: index.isEven ? 0.72 : 0.56,
                ),
              ),
              Expanded(
                child: _PlaceholderBar(
                  color: color,
                  alignment: Alignment.centerRight,
                  widthFactor: index.isEven ? 0.48 : 0.64,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlaceholderBar extends StatelessWidget {
  final Color color;
  final Alignment alignment;
  final double widthFactor;

  const _PlaceholderBar({
    required this.color,
    required this.alignment,
    required this.widthFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
