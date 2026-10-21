import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/weather_models.dart';
import '../../providers/weather_providers.dart';
import 'glass_card.dart';

/// "Rain likely around 3 PM (70%)" for the next few hours, else null.
String? rainAlertMessage(List<HourlyItem> hourly) {
  final upcoming = hourly.take(4).toList();
  for (var i = 0; i < upcoming.length; i++) {
    final p = upcoming[i].precipitationProbability;
    if (p != null && p >= 50) {
      final when = i == 0
          ? 'now'
          : 'around ${DateFormat('h a').format(upcoming[i].time)}';
      return 'Rain likely $when ($p% chance)';
    }
  }
  return null;
}

class RainAlertBanner extends StatelessWidget {
  const RainAlertBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + AppSpacing.xs,
      ),
      child: Row(
        children: [
          const Icon(Icons.umbrella, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message, style: text.bodyLarge)),
        ],
      ),
    );
  }
}

/// Shown when saved data is displayed because the update failed.
class StaleBanner extends ConsumerWidget {
  const StaleBanner({super.key, required this.fetchedAt});

  final DateTime fetchedAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final color = Theme.of(context).iconTheme.color ?? Colors.white;
    final when = DateFormat('MMM d, h:mm a').format(fetchedAt.toLocal());

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              "Couldn't update. Saved data from $when.",
              style: text.labelMedium,
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: color),
            onPressed: () => ref.read(weatherProvider.notifier).retry(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
