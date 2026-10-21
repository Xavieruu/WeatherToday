import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/weather_code_mapper.dart';
import '../../domain/weather_models.dart';
import 'temp_text.dart';

/// Big temperature, condition, feels-like and today's high/low.
class CurrentWeatherHeader extends StatelessWidget {
  const CurrentWeatherHeader({
    super.key,
    required this.current,
    required this.today,
  });

  final CurrentWeather current;
  final DailyItem today;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final info = weatherInfoFor(current.weatherCode);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          Icon(info.icon(current.isDay), size: 64),
          const SizedBox(height: AppSpacing.sm),
          TempText(current.temperature, style: text.displayLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(info.label, style: text.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              _Labeled('Feels like', current.apparentTemperature, text),
              _Labeled('H', today.tempMax, text),
              _Labeled('L', today.tempMin, text),
            ],
          ),
        ],
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled(this.label, this.celsius, this.text);

  final String label;
  final double celsius;
  final TextTheme text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label ', style: text.labelMedium),
        TempText(celsius, style: text.bodyLarge),
      ],
    );
  }
}
