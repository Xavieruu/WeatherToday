/// Current air quality from the Open-Meteo air-quality API
/// (`current.us_aqi`, `current.pm2_5`, `current.pm10`).
class AirQuality {
  const AirQuality({required this.usAqi, this.pm25, this.pm10});

  final int usAqi;
  final double? pm25;
  final double? pm10;

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    if (current is! Map<String, dynamic>) {
      throw const FormatException('missing current');
    }
    return AirQuality(
      usAqi: (current['us_aqi'] as num).round(),
      pm25: current['pm2_5'] is num ? (current['pm2_5'] as num).toDouble() : null,
      pm10: current['pm10'] is num ? (current['pm10'] as num).toDouble() : null,
    );
  }
}
