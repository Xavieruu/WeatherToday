import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';

class GeocodingApi {
  GeocodingApi(this._dio);

  final Dio _dio;

  static const _url = 'https://geocoding-api.open-meteo.com/v1/search';

  /// Returns the decoded JSON body. When nothing matches, Open-Meteo omits
  /// the `results` key entirely.
  Future<Map<String, dynamic>> search(
    String query, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<dynamic>(
      _url,
      queryParameters: {
        'name': query,
        'count': 5,
        'language': 'en',
        'format': 'json',
      },
      cancelToken: cancelToken,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw const ApiException(
      ApiErrorType.malformed,
      'Received unexpected data from the search service.',
    );
  }
}
