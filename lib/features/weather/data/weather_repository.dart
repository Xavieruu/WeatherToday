import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/prefs_service.dart';
import '../../search/domain/city_result.dart';
import '../domain/air_quality.dart';
import '../domain/weather_models.dart';
import 'weather_api.dart';

class WeatherRepository {
  WeatherRepository(this._api, this._prefs);

  final WeatherApi _api;
  final PrefsService _prefs;

  Future<WeatherData> fetchWeather(CityResult city) async {
    try {
      final json = await _api.fetchForecast(
        latitude: city.latitude,
        longitude: city.longitude,
      );
      final data = WeatherData.fromJson(json);
      // Only data that parsed correctly is saved.
      try {
        await _prefs.writeForecastCache(city.key, json);
      } catch (_) {
        // Caching is best-effort.
      }
      return data;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw mapDioException(e);
    } catch (_) {
      // Missing keys, nulls, bad dates, length mismatches.
      throw const ApiException(
        ApiErrorType.malformed,
        'Received unexpected data from the weather service.',
      );
    }
  }

  /// The last saved forecast for [city], marked stale, or null.
  WeatherData? cached(CityResult city) {
    final saved = _prefs.readForecastCache(city.key);
    if (saved == null) return null;
    try {
      return WeatherData.fromJson(
        saved.data,
        fetchedAt: saved.fetchedAt,
        isStale: true,
      );
    } catch (_) {
      return null;
    }
  }

  /// Air quality is a bonus: any failure just means "not available".
  Future<AirQuality?> fetchAirQuality(CityResult city) async {
    try {
      final json = await _api.fetchAirQuality(
        latitude: city.latitude,
        longitude: city.longitude,
      );
      return AirQuality.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
