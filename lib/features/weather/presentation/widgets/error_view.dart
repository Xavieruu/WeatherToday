import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';

/// Full-screen error / offline state with a Retry button.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.offline,
    required this.message,
    required this.onRetry,
  });

  final bool offline;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(offline ? Icons.wifi_off : Icons.error_outline, size: 64),
            const SizedBox(height: AppSpacing.md),
            Text(
              offline ? "You're offline" : 'Something went wrong',
              style: text.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              offline ? 'Check your connection and try again.' : message,
              style: text.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
