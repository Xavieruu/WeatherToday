import 'package:flutter/material.dart';

import 'weather_code_mapper.dart';

/// Gradient per condition group and day/night (plan.md section 4).
/// Values are tuned starting points; adjust on device for contrast.
class WeatherGradients {
  WeatherGradients._();

  /// Shown before data has loaded.
  static const List<Color> fallback = [Color(0xFF5B8FD9), Color(0xFF8FB6E8)];

  static List<Color> colors(WeatherGroup group, bool isDay) {
    switch (group) {
      case WeatherGroup.clear:
        return isDay
            ? const [Color(0xFF2F80ED), Color(0xFF56CCF2)]
            : const [Color(0xFF0F2027), Color(0xFF2C5364)];
      case WeatherGroup.partlyCloudy:
        return isDay
            ? const [Color(0xFF5B8FD9), Color(0xFF8FB6E8)]
            : const [Color(0xFF1B2A49), Color(0xFF3A4A6B)];
      case WeatherGroup.overcast:
        return isDay
            ? const [Color(0xFF7B8A97), Color(0xFFA3B0BA)]
            : const [Color(0xFF232B33), Color(0xFF3C4650)];
      case WeatherGroup.fog:
        return isDay
            ? const [Color(0xFFAEB8C0), Color(0xFFD3DADF)]
            : const [Color(0xFF2F3640), Color(0xFF4A525C)];
      case WeatherGroup.drizzle:
        return isDay
            ? const [Color(0xFF6C8DA6), Color(0xFF9BB3C6)]
            : const [Color(0xFF1F2D3A), Color(0xFF3A4B5A)];
      case WeatherGroup.rain:
        return isDay
            ? const [Color(0xFF4B6C8C), Color(0xFF7A98B3)]
            : const [Color(0xFF141E30), Color(0xFF243B55)];
      case WeatherGroup.snow:
        return isDay
            ? const [Color(0xFF9CB8CE), Color(0xFFC9DAE8)]
            : const [Color(0xFF2B3A4F), Color(0xFF4E6580)];
      case WeatherGroup.thunderstorm:
        return isDay
            ? const [Color(0xFF3A3F58), Color(0xFF5C5F7A)]
            : const [Color(0xFF0B0C1A), Color(0xFF262A44)];
    }
  }

  /// Text/icon color that stays readable on the given gradient.
  static Color onColor(List<Color> colors) {
    final mid = Color.lerp(colors.first, colors.last, 0.5)!;
    return mid.computeLuminance() > 0.45
        ? const Color(0xFF14212B)
        : Colors.white;
  }
}
