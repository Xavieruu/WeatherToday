import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/async_value_ext.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../search/domain/city_result.dart';
import '../../domain/weather_models.dart';
import '../../providers/weather_providers.dart';
import 'glass_card.dart';

/// Grid of detail cards: humidity, wind, rain chance, UV, air quality,
/// pressure, visibility, sunrise/sunset.
class DetailCards extends ConsumerWidget {
  const DetailCards({super.key, required this.data, required this.city});

  final WeatherData data;
  final CityResult city;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = data.current;
    final today = data.daily.first;
    final timeFormat = DateFormat('h:mm a');
    final air = ref.watch(airQualityProvider(city)).safeValue;
    final rain = today.precipitationProbabilityMax;
    final windFrom = c.windDirection;

    final tiles = <Widget>[
      _Tile(
        icon: Icons.water_drop_outlined,
        label: 'Humidity',
        value: '${c.humidity}%',
      ),
      _Tile(
        icon: Icons.air,
        label: 'Wind',
        value: '${c.windSpeed.round()} km/h',
        subtitle: windFrom == null ? null : 'From ${compassDirection(windFrom)}',
      ),
      _Tile(
        icon: Icons.umbrella_outlined,
        label: 'Rain chance',
        value: rain == null ? '—' : '$rain%',
        subtitle: 'Today',
      ),
      _Tile(
        icon: Icons.wb_sunny_outlined,
        label: 'UV index',
        value: data.uvIndex.toStringAsFixed(1),
        subtitle: uvLabel(data.uvIndex),
      ),
      _Tile(
        icon: Icons.masks_outlined,
        label: 'Air quality',
        value: air == null ? '—' : '${air.usAqi}',
        subtitle: air == null ? null : aqiLabel(air.usAqi),
      ),
      _Tile(
        icon: Icons.speed,
        label: 'Pressure',
        value: '${c.pressure.round()} hPa',
      ),
      _Tile(
        icon: Icons.visibility_outlined,
        label: 'Visibility',
        value: data.visibility == null
            ? '—'
            : '${(data.visibility! / 1000).toStringAsFixed(1)} km',
      ),
      _Tile(
        icon: Icons.wb_twilight,
        label: 'Sunrise',
        value: today.sunrise == null ? '—' : timeFormat.format(today.sunrise!),
        subtitle: today.sunset == null
            ? null
            : 'Sunset ${timeFormat.format(today.sunset!)}',
      ),
    ];

    final rows = <Widget>[];
    for (var i = 0; i < tiles.length; i += 2) {
      if (rows.isNotEmpty) {
        rows.add(const SizedBox(height: AppSpacing.cardGap));
      }
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: tiles[i]),
              const SizedBox(width: AppSpacing.cardGap),
              Expanded(child: tiles[i + 1]),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return GlassCard(
      blur: false,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: text.labelMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: text.titleMedium?.copyWith(fontSize: 24),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle!, style: text.labelMedium),
            ],
          ],
        ),
      ),
    );
  }
}
