// Unit tests for the app's pure logic (no UI, no network).
// Run with: flutter test
//
// NOTE: the import paths use the package name from pubspec.yaml
// (`name: weather_today`). If yours differs, change the prefix below.
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_today/core/utils/format_utils.dart';
import 'package:weather_today/core/utils/units.dart';
import 'package:weather_today/features/search/domain/city_result.dart';
import 'package:weather_today/features/weather/domain/weather_code_mapper.dart';
import 'package:weather_today/features/weather/domain/weather_models.dart';

String _stamp(DateTime t) => t.toIso8601String().substring(0, 16);

/// A forecast shaped like the Open-Meteo response: 48 hourly slots from
/// 2026-10-20 00:00 and 7 days. "Now" is 13:45.
Map<String, dynamic> _sampleForecast({bool polar = false}) {
  final start = DateTime(2026, 10, 20);
  return {
    'utc_offset_seconds': 28800,
    'current': <String, dynamic>{
      'time': '2026-10-20T13:45',
      'temperature_2m': 31.2,
      'relative_humidity_2m': 64,
      'apparent_temperature': 36.0,
      'is_day': 1,
      'weather_code': 2,
      'pressure_msl': 1009.8,
      'wind_speed_10m': 11.4,
      'wind_direction_10m': 225,
    },
    'hourly': <String, dynamic>{
      'time': List.generate(48, (i) => _stamp(start.add(Duration(hours: i)))),
      'temperature_2m': List.generate(48, (i) => 25.0 + i % 8),
      'weather_code': List.generate(48, (_) => 1),
      'is_day': List.generate(48, (i) => i % 24 >= 6 && i % 24 < 18 ? 1 : 0),
      'uv_index': List.generate(48, (i) => i.toDouble()),
      'visibility': List.generate(48, (_) => 24140.0),
      'precipitation_probability': List.generate(48, (i) => i % 100),
    },
    'daily': <String, dynamic>{
      'time': List.generate(
        7,
        (i) => _stamp(start.add(Duration(days: i))).substring(0, 10),
      ),
      'weather_code': List.generate(7, (_) => 61),
      'temperature_2m_max': List.generate(7, (_) => 32.5),
      'temperature_2m_min': List.generate(7, (_) => 26.0),
      'sunrise': List.generate(7, (_) => polar ? null : '2026-10-20T05:51'),
      'sunset': List.generate(7, (_) => polar ? null : '2026-10-20T17:30'),
      'precipitation_probability_max': List.generate(7, (i) => 40 + i),
    },
  };
}

void main() {
  group('TempUnit', () {
    test('converts Celsius to Fahrenheit', () {
      expect(TempUnit.fahrenheit.convert(0), 32);
      expect(TempUnit.fahrenheit.convert(100), 212);
      expect(TempUnit.fahrenheit.convert(25), 77);
    });

    test('leaves Celsius unchanged', () {
      expect(TempUnit.celsius.convert(24.4), 24.4);
    });

    test('formats with rounding and degree sign', () {
      expect(TempUnit.celsius.format(24.4), '24°');
      expect(TempUnit.celsius.format(24.6), '25°');
      expect(TempUnit.fahrenheit.format(25), '77°');
    });
  });

  group('format helpers', () {
    test('compassDirection', () {
      expect(compassDirection(0), 'N');
      expect(compassDirection(45), 'NE');
      expect(compassDirection(90), 'E');
      expect(compassDirection(200), 'S');
      expect(compassDirection(225), 'SW');
      expect(compassDirection(350), 'N');
      expect(compassDirection(360), 'N');
    });

    test('aqiLabel', () {
      expect(aqiLabel(42), 'Good');
      expect(aqiLabel(75), 'Moderate');
      expect(aqiLabel(120), 'Unhealthy for sensitive groups');
      expect(aqiLabel(180), 'Unhealthy');
      expect(aqiLabel(250), 'Very unhealthy');
      expect(aqiLabel(400), 'Hazardous');
    });

    test('uvLabel', () {
      expect(uvLabel(2.9), 'Low');
      expect(uvLabel(4), 'Moderate');
      expect(uvLabel(6), 'High');
      expect(uvLabel(9), 'Very high');
      expect(uvLabel(12), 'Extreme');
    });
  });

  group('weatherInfoFor', () {
    test('maps known codes', () {
      expect(weatherInfoFor(0).group, WeatherGroup.clear);
      expect(weatherInfoFor(2).label, 'Partly cloudy');
      expect(weatherInfoFor(63).group, WeatherGroup.rain);
      expect(weatherInfoFor(95).group, WeatherGroup.thunderstorm);
    });

    test('unknown code falls back to overcast', () {
      final info = weatherInfoFor(1234);
      expect(info.label, 'Unknown');
      expect(info.group, WeatherGroup.overcast);
    });
  });

  group('CityResult', () {
    test('parses geocoding JSON and round-trips', () {
      final city = CityResult.fromJson({
        'id': 1701668,
        'name': 'Manila',
        'latitude': 14.6042,
        'longitude': 120.9822,
        'country': 'Philippines',
        'admin1': 'Metro Manila',
        'timezone': 'Asia/Manila',
      });
      expect(city.name, 'Manila');
      expect(city.subtitle, 'Metro Manila, Philippines');
      final copy = CityResult.fromJson(city.toJson());
      expect(copy, city);
    });

    test('same coordinates are the same place', () {
      const a = CityResult(
          id: 1, name: 'Manila', latitude: 14.6042, longitude: 120.9822);
      const b = CityResult(
          id: -1, name: 'Manila', latitude: 14.6040, longitude: 120.9820);
      expect(a, b);
      expect({a, b}.length, 1);
    });

    test('different places are different', () {
      const a = CityResult(id: 1, name: 'A', latitude: 1, longitude: 1);
      const b = CityResult(id: 1, name: 'A', latitude: 2, longitude: 2);
      expect(a == b, isFalse);
    });
  });

  group('WeatherData.fromJson', () {
    test('parses current conditions', () {
      final data = WeatherData.fromJson(_sampleForecast());
      expect(data.current.temperature, 31.2);
      expect(data.current.isDay, isTrue);
      expect(data.current.windDirection, 225);
      expect(data.utcOffsetSeconds, 28800);
      expect(data.isStale, isFalse);
    });

    test('hourly strip is 24 items starting at the current hour', () {
      final data = WeatherData.fromJson(_sampleForecast());
      expect(data.hourly.length, 24);
      expect(data.hourly.first.time.hour, 13);
      expect(data.hourly.last.time, DateTime(2026, 10, 21, 12));
      expect(data.hourly.first.precipitationProbability, 13);
    });

    test('UV and visibility come from the current hour', () {
      final data = WeatherData.fromJson(_sampleForecast());
      expect(data.uvIndex, 13.0);
      expect(data.visibility, 24140.0);
    });

    test('has 7 daily items with rain chance', () {
      final data = WeatherData.fromJson(_sampleForecast());
      expect(data.daily.length, 7);
      expect(data.daily.first.precipitationProbabilityMax, 40);
      expect(data.daily.first.sunrise, DateTime(2026, 10, 20, 5, 51));
    });

    test('missing sunrise/sunset (polar day) does not fail', () {
      final data = WeatherData.fromJson(_sampleForecast(polar: true));
      expect(data.daily.first.sunrise, isNull);
      expect(data.daily.first.sunset, isNull);
    });

    test('missing optional rain arrays do not fail', () {
      final json = _sampleForecast();
      (json['hourly'] as Map).remove('precipitation_probability');
      (json['daily'] as Map).remove('precipitation_probability_max');
      final data = WeatherData.fromJson(json);
      expect(data.hourly.first.precipitationProbability, isNull);
      expect(data.daily.first.precipitationProbabilityMax, isNull);
    });

    test('stale flag and fetch time are carried through', () {
      final at = DateTime(2026, 10, 20, 9);
      final data =
          WeatherData.fromJson(_sampleForecast(), fetchedAt: at, isStale: true);
      expect(data.isStale, isTrue);
      expect(data.fetchedAt, at);
    });

    test('malformed data throws', () {
      expect(() => WeatherData.fromJson({}), throwsA(anything));
      final broken = _sampleForecast();
      (broken['hourly'] as Map)['temperature_2m'] = <dynamic>[];
      expect(() => WeatherData.fromJson(broken), throwsA(anything));
    });
  });
}
