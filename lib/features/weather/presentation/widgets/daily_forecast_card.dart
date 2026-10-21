import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/weather_code_mapper.dart';
import '../../domain/weather_models.dart';
import 'glass_card.dart';
import 'temp_text.dart';

/// 7-day list: weekday, icon, low and high.
class DailyForecastCard extends StatelessWidget {
  const DailyForecastCard({super.key, required this.items});

  final List<DailyItem> items;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dayFormat = DateFormat('EEEE');

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('7-day forecast', style: text.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      i == 0 ? 'Today' : dayFormat.format(items[i].date),
                      style: text.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    weatherInfoFor(items[i].weatherCode).icon(true),
                    size: 24,
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Opacity(
                          opacity: 0.7,
                          child: TempText(items[i].tempMin,
                              style: text.bodyLarge),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        TempText(
                          items[i].tempMax,
                          style: text.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
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
