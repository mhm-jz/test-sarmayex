import 'package:flutter/material.dart';

import '../bloc/trading/trading_state.dart';

class RealtimeStatusBanner extends StatelessWidget {
  final TradingConnectionStatus status;
  final String? message;
  final VoidCallback onRetry;

  const RealtimeStatusBanner({
    super.key,
    required this.status,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (status) {
      TradingConnectionStatus.initial ||
      TradingConnectionStatus.connecting =>
        const SizedBox.shrink(),
      TradingConnectionStatus.connected => const SizedBox.shrink(),
      TradingConnectionStatus.reconnecting => _StatusPanel(
          icon: Icons.sync_problem,
          message:
              message ?? 'Connection lost. Showing latest order book snapshot.',
          actionLabel: 'Update',
          onAction: onRetry,
          backgroundColor: colorScheme.tertiaryContainer,
          foregroundColor: colorScheme.onTertiaryContainer,
        ),
      TradingConnectionStatus.failure => _StatusPanel(
          icon: Icons.error_outline,
          message: message ?? 'Could not connect.',
          actionLabel: 'Retry',
          onAction: onRetry,
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
        ),
    };
  }
}

class _StatusPanel extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final Color backgroundColor;
  final Color foregroundColor;

  const _StatusPanel({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: foregroundColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: foregroundColor,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: foregroundColor,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
