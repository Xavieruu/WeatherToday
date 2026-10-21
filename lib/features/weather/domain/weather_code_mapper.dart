import 'package:flutter/material.dart';

enum WeatherGroup {
  clear,
  partlyCloudy,
  overcast,
  fog,
  drizzle,
  rain,
  snow,
  thunderstorm,
}

class WeatherInfo {
  const WeatherInfo(this.label, this.group, this.dayIcon, this.nightIcon);

  final String label;
  final WeatherGroup group;
  final IconData dayIcon;
  final IconData nightIcon;

  IconData icon(bool isDay) => isDay ? dayIcon : nightIcon;
}

/// Maps a WMO weather code (Open-Meteo `weather_code`) to label, icon, group.
WeatherInfo weatherInfoFor(int code) {
  switch (code) {
    case 0:
      return const WeatherInfo('Clear sky', WeatherGroup.clear,
          Icons.wb_sunny, Icons.nightlight_round);
    case 1:
      return const WeatherInfo('Mainly clear', WeatherGroup.partlyCloudy,
          Icons.wb_sunny, Icons.nightlight_round);
    case 2:
      return const WeatherInfo('Partly cloudy', WeatherGroup.partlyCloudy,
          Icons.wb_cloudy, Icons.nights_stay);
    case 3:
      return const WeatherInfo(
          'Overcast', WeatherGroup.overcast, Icons.cloud, Icons.cloud);
    case 45:
      return const WeatherInfo(
          'Fog', WeatherGroup.fog, Icons.foggy, Icons.foggy);
    case 48:
      return const WeatherInfo(
          'Rime fog', WeatherGroup.fog, Icons.foggy, Icons.foggy);
    case 51:
      return const WeatherInfo('Light drizzle', WeatherGroup.drizzle,
          Icons.grain, Icons.grain);
    case 53:
      return const WeatherInfo(
          'Drizzle', WeatherGroup.drizzle, Icons.grain, Icons.grain);
    case 55:
      return const WeatherInfo('Heavy drizzle', WeatherGroup.drizzle,
          Icons.grain, Icons.grain);
    case 56:
      return const WeatherInfo('Freezing drizzle', WeatherGroup.drizzle,
          Icons.grain, Icons.grain);
    case 57:
      return const WeatherInfo('Heavy freezing drizzle', WeatherGroup.drizzle,
          Icons.grain, Icons.grain);
    case 61:
      return const WeatherInfo('Light rain', WeatherGroup.rain,
          Icons.water_drop, Icons.water_drop);
    case 63:
      return const WeatherInfo(
          'Rain', WeatherGroup.rain, Icons.water_drop, Icons.water_drop);
    case 65:
      return const WeatherInfo('Heavy rain', WeatherGroup.rain,
          Icons.water_drop, Icons.water_drop);
    case 66:
      return const WeatherInfo('Freezing rain', WeatherGroup.rain,
          Icons.water_drop, Icons.water_drop);
    case 67:
      return const WeatherInfo('Heavy freezing rain', WeatherGroup.rain,
          Icons.water_drop, Icons.water_drop);
    case 71:
      return const WeatherInfo('Light snow', WeatherGroup.snow,
          Icons.ac_unit, Icons.ac_unit);
    case 73:
      return const WeatherInfo(
          'Snow', WeatherGroup.snow, Icons.ac_unit, Icons.ac_unit);
    case 75:
      return const WeatherInfo('Heavy snow', WeatherGroup.snow,
          Icons.ac_unit, Icons.ac_unit);
    case 77:
      return const WeatherInfo('Snow grains', WeatherGroup.snow,
          Icons.ac_unit, Icons.ac_unit);
    case 80:
      return const WeatherInfo('Light showers', WeatherGroup.rain,
          Icons.water_drop, Icons.water_drop);
    case 81:
      return const WeatherInfo(
          'Showers', WeatherGroup.rain, Icons.water_drop, Icons.water_drop);
    case 82:
      return const WeatherInfo('Violent showers', WeatherGroup.rain,
          Icons.water_drop, Icons.water_drop);
    case 85:
      return const WeatherInfo('Light snow showers', WeatherGroup.snow,
          Icons.ac_unit, Icons.ac_unit);
    case 86:
      return const WeatherInfo('Snow showers', WeatherGroup.snow,
          Icons.ac_unit, Icons.ac_unit);
    case 95:
      return const WeatherInfo('Thunderstorm', WeatherGroup.thunderstorm,
          Icons.thunderstorm, Icons.thunderstorm);
    case 96:
      return const WeatherInfo('Thunderstorm with hail',
          WeatherGroup.thunderstorm, Icons.thunderstorm, Icons.thunderstorm);
    case 99:
      return const WeatherInfo('Thunderstorm with heavy hail',
          WeatherGroup.thunderstorm, Icons.thunderstorm, Icons.thunderstorm);
    default:
      // Unknown code: neutral cloud + overcast gradient (plan.md section 8).
      return const WeatherInfo(
          'Unknown', WeatherGroup.overcast, Icons.cloud, Icons.cloud);
  }
}
