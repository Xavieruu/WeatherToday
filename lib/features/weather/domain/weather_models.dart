// Models for the Open-Meteo forecast response (see plan.md sections 6-7).
//
// Times are strings in the city's local time (`timezone=auto`) with no UTC
// offset, so `DateTime.parse` yields wall-clock values that are formatted
// as-is.

class CurrentWeather {
  const CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.isDay,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.time,
  });

  final double temperature; // current.temperature_2m (°C)
  final double apparentTemperature; // current.apparent_temperature (°C)
  final int weatherCode; // current.weather_code
  final bool isDay; // current.is_day
  final int humidity; // current.relative_humidity_2m (%)
  final double windSpeed; // current.wind_speed_10m (km/h)
  final int? windDirection; // current.wind_direction_10m (degrees)
  final double pressure; // current.pressure_msl (hPa)
  final DateTime time; // current.time

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: _toDouble(json['temperature_2m']),
      apparentTemperature: _toDouble(json['apparent_temperature']),
      weatherCode: _toInt(json['weather_code']),
      isDay: _toInt(json['is_day']) == 1,
      humidity: _toInt(json['relative_humidity_2m']),
      windSpeed: _toDouble(json['wind_speed_10m']),
      windDirection: _toIntOrNull(json['wind_direction_10m']),
      pressure: _toDouble(json['pressure_msl']),
      time: DateTime.parse(json['time'] as String),
    );
  }
}

class HourlyItem {
  const HourlyItem({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.isDay,
    this.precipitationProbability,
  });

  final DateTime time; // hourly.time[i]
  final double temperature; // hourly.temperature_2m[i]
  final int weatherCode; // hourly.weather_code[i]
  final bool isDay; // hourly.is_day[i]
  final int? precipitationProbability; // hourly.precipitation_probability[i]
}

class DailyItem {
  const DailyItem({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.sunrise,
    required this.sunset,
    this.precipitationProbabilityMax,
  });

  final DateTime date; // daily.time[i]
  final int weatherCode; // daily.weather_code[i]
  final double tempMax; // daily.temperature_2m_max[i]
  final double tempMin; // daily.temperature_2m_min[i]
  final DateTime? sunrise; // daily.sunrise[i] (null in polar day/night)
  final DateTime? sunset; // daily.sunset[i] (null in polar day/night)
  final int? precipitationProbabilityMax; // daily.precipitation_probability_max[i]
}

class WeatherData {
  const WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.uvIndex,
    required this.visibility,
    required this.utcOffsetSeconds,
    required this.fetchedAt,
    this.isStale = false,
  });

  final CurrentWeather current;

  /// The 24 hours starting at the current hour.
  final List<HourlyItem> hourly;

  /// 7 days, first item is today.
  final List<DailyItem> daily;

  /// hourly.uv_index at the current hour.
  final double uvIndex;

  /// hourly.visibility (metres) at the current hour; null if unavailable.
  final double? visibility;

  /// Top-level `utc_offset_seconds` (city's offset from UTC).
  final int utcOffsetSeconds;

  /// When this data was downloaded (device clock).
  final DateTime fetchedAt;

  /// True when this is saved data shown because a refresh failed.
  final bool isStale;

  /// Current wall-clock time in the city. The returned DateTime is flagged
  /// UTC only so its fields hold the city's local clock values.
  DateTime get cityNow =>
      DateTime.now().toUtc().add(Duration(seconds: utcOffsetSeconds));

  factory WeatherData.fromJson(
    Map<String, dynamic> json, {
    DateTime? fetchedAt,
    bool isStale = false,
  }) {
    final current = CurrentWeather.fromJson(_asMap(json['current']));

    // Hourly arrays.
    final h = _asMap(json['hourly']);
    final times = _asList(h['time']);
    final temps = _asList(h['temperature_2m']);
    final codes = _asList(h['weather_code']);
    final isDays = _asList(h['is_day']);
    final uvs = _asList(h['uv_index']);
    final vis = _asList(h['visibility']);
    final rain = h['precipitation_probability'] is List
        ? h['precipitation_probability'] as List
        : const <dynamic>[];
    final n = times.length;
    if (n == 0 ||
        temps.length < n ||
        codes.length < n ||
        isDays.length < n ||
        uvs.length < n ||
        vis.length < n) {
      throw const FormatException('hourly arrays are inconsistent');
    }

    // Index of the current hour (first hourly slot not before it).
    final t = current.time;
    final currentHour = DateTime(t.year, t.month, t.day, t.hour);
    var start = 0;
    for (var i = 0; i < n; i++) {
      final slot = DateTime.parse(times[i] as String);
      if (!slot.isBefore(currentHour)) {
        start = i;
        break;
      }
    }
    final end = start + 24 < n ? start + 24 : n;

    final hourly = <HourlyItem>[
      for (var i = start; i < end; i++)
        HourlyItem(
          time: DateTime.parse(times[i] as String),
          temperature: _toDouble(temps[i]),
          weatherCode: _toInt(codes[i]),
          isDay: _toInt(isDays[i]) == 1,
          precipitationProbability:
              i < rain.length ? _toIntOrNull(rain[i]) : null,
        ),
    ];

    // Daily arrays.
    final d = _asMap(json['daily']);
    final dTimes = _asList(d['time']);
    final dCodes = _asList(d['weather_code']);
    final dMax = _asList(d['temperature_2m_max']);
    final dMin = _asList(d['temperature_2m_min']);
    final dRise = _asList(d['sunrise']);
    final dSet = _asList(d['sunset']);
    final dRain = d['precipitation_probability_max'] is List
        ? d['precipitation_probability_max'] as List
        : const <dynamic>[];
    final dn = dTimes.length;
    if (dn == 0 ||
        dCodes.length < dn ||
        dMax.length < dn ||
        dMin.length < dn ||
        dRise.length < dn ||
        dSet.length < dn) {
      throw const FormatException('daily arrays are inconsistent');
    }

    final daily = <DailyItem>[
      for (var i = 0; i < dn; i++)
        DailyItem(
          date: DateTime.parse(dTimes[i] as String),
          weatherCode: _toInt(dCodes[i]),
          tempMax: _toDouble(dMax[i]),
          tempMin: _toDouble(dMin[i]),
          sunrise: _parseOrNull(dRise[i]),
          sunset: _parseOrNull(dSet[i]),
          precipitationProbabilityMax:
              i < dRain.length ? _toIntOrNull(dRain[i]) : null,
        ),
    ];

    return WeatherData(
      current: current,
      hourly: hourly,
      daily: daily,
      uvIndex: _toDoubleOrZero(uvs[start]),
      visibility: vis[start] is num ? (vis[start] as num).toDouble() : null,
      utcOffsetSeconds: _toIntOrNull(json['utc_offset_seconds']) ?? 0,
      fetchedAt: fetchedAt ?? DateTime.now(),
      isStale: isStale,
    );
  }
}

// Helpers. Casting null to num throws, which the repository reports as
// malformed data.
double _toDouble(dynamic v) => (v as num).toDouble();
int _toInt(dynamic v) => (v as num).round();
int? _toIntOrNull(dynamic v) => v is num ? v.round() : null;
double _toDoubleOrZero(dynamic v) => v is num ? v.toDouble() : 0;
DateTime? _parseOrNull(dynamic v) => v is String ? DateTime.tryParse(v) : null;

Map<String, dynamic> _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  throw const FormatException('expected an object');
}

List<dynamic> _asList(dynamic v) {
  if (v is List) return v;
  throw const FormatException('expected a list');
}
