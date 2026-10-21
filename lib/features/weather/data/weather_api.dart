import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';

class WeatherApi {
  WeatherApi(this._dio);

  final Dio _dio;

  static const _url = 'https://api.open-meteo.com/v1/forecast';

  Future<Map<String, dynamic>> fetchForecast({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.get<dynamic>(
      _url,
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,'
            'is_day,weather_code,pressure_msl,wind_speed_10m',
        'hourly': 'temperature_2m,weather_code,is_day,uv_index,visibility',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min,'
            'sunrise,sunset',
        'forecast_days': 7,
        'timezone': 'auto',
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw const ApiException(
      ApiErrorType.malformed,
      'Received unexpected data from the weather service.',
    );
  }
}
