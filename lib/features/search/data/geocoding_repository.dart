import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/city_result.dart';
import 'geocoding_api.dart';

class GeocodingRepository {
  GeocodingRepository(this._api);

  final GeocodingApi _api;

  Future<List<CityResult>> search(
    String query, {
    CancelToken? cancelToken,
  }) async {
    try {
      final data = await _api.search(query, cancelToken: cancelToken);
      final results = data['results'];
      if (results == null) return const [];
      if (results is! List) {
        throw const FormatException('results is not a list');
      }
      return results
          .whereType<Map<String, dynamic>>()
          .map(CityResult.fromJson)
          .toList();
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw mapDioException(e);
    } catch (_) {
      throw const ApiException(
        ApiErrorType.malformed,
        'Received unexpected data from the search service.',
      );
    }
  }
}
