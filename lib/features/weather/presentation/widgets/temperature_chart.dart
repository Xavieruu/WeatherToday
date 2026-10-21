import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/units.dart';
import '../../../settings/providers/settings_providers.dart';
import '../../domain/weather_models.dart';
import 'glass_card.dart';

/// Line chart of the temperature over the next 24 hours.
class TemperatureChart extends ConsumerWidget {
  const TemperatureChart({super.key, required this.items});

  final List<HourlyItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.length < 2) return const SizedBox.shrink();

    final unit = ref.watch(temperatureUnitProvider);
    final text = Theme.of(context).textTheme;
    final color = Theme.of(context).iconTheme.color ?? Colors.white;
    final hourFormat = DateFormat('h a');

    final values = [for (final h in items) unit.convert(h.temperature)];
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);

    final spots = [
      for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Temperature trend', style: text.titleMedium),
              ),
              Text(
                'H ${maxV.round()}°  L ${minV.round()}°',
                style: text.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 160,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (values.length - 1).toDouble(),
                minY: minV - 2,
                maxY: maxV + 2,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 6,
                      getTitlesWidget: (value, meta) {
                        final i = value.round();
                        if (i < 0 || i >= items.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            i == 0 ? 'Now' : hourFormat.format(items[i].time),
                            style: text.labelMedium,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
