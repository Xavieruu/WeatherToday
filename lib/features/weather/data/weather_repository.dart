import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../search/domain/city_result.dart';
import '../domain/weather_models.dart';
import 'weather_api.dart';

class WeatherRepository {
  WeatherRepository(this._api);

  final WeatherApi _api;

  Future<WeatherData> fetchWeather(CityResult city) async {
    try {
      final json = await _api.fetchForecast(
        latitude: city.latitude,
        longitude: city.longitude,
      );
      return WeatherData.fromJson(json);
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
}
