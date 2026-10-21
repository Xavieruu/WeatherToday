import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/weather_code_mapper.dart';
import '../../domain/weather_models.dart';
import 'glass_card.dart';
import 'temp_text.dart';

/// Horizontally scrollable strip for the next 24 hours.
class HourlyStrip extends StatelessWidget {
  const HourlyStrip({super.key, required this.items});

  final List<HourlyItem> items;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final hourFormat = DateFormat('h a');

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('Next 24 hours', style: text.titleMedium),
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  SizedBox(
                    width: 64,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          i == 0 ? 'Now' : hourFormat.format(items[i].time),
                          style: text.labelMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Icon(
                          weatherInfoFor(items[i].weatherCode)
                              .icon(items[i].isDay),
                          size: 28,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TempText(items[i].temperature, style: text.bodyLarge),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
