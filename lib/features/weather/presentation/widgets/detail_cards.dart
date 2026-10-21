import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/weather_models.dart';
import 'glass_card.dart';

/// Grid of detail cards: humidity, wind, UV, pressure, visibility, sun times.
class DetailCards extends StatelessWidget {
  const DetailCards({super.key, required this.data});

  final WeatherData data;

  static String _uvLabel(double uv) {
    if (uv < 3) return 'Low';
    if (uv < 6) return 'Moderate';
    if (uv < 8) return 'High';
    if (uv < 11) return 'Very high';
    return 'Extreme';
  }

  @override
  Widget build(BuildContext context) {
    final c = data.current;
    final today = data.daily.first;
    final timeFormat = DateFormat('h:mm a');

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
      ),
      _Tile(
        icon: Icons.wb_sunny_outlined,
        label: 'UV index',
        value: data.uvIndex.toStringAsFixed(1),
        subtitle: _uvLabel(data.uvIndex),
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
        subtitle: 'Sunset ${today.sunset == null ? '—' : timeFormat.format(today.sunset!)}',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(label, style: text.labelMedium),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: text.titleMedium?.copyWith(fontSize: 24)),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle!, style: text.labelMedium),
          ],
        ],
      ),
    );
  }
}
