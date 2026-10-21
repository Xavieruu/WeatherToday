import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_exception.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
});

/// Maps a Dio failure to an [ApiException] the UI can show.
ApiException mapDioException(DioException e) {
  final t = e.type;
  if (t == DioExceptionType.connectionError ||
      t == DioExceptionType.connectionTimeout ||
      t == DioExceptionType.sendTimeout ||
      t == DioExceptionType.receiveTimeout) {
    return const ApiException(ApiErrorType.offline, "You're offline");
  }
  if (t == DioExceptionType.badResponse) {
    final code = e.response?.statusCode;
    return ApiException(
      ApiErrorType.server,
      code == null
          ? 'The weather service returned an error.'
          : 'The weather service returned an error ($code).',
    );
  }
  if (t == DioExceptionType.cancel) {
    return const ApiException(ApiErrorType.unknown, 'Request cancelled');
  }
  if (e.error is SocketException) {
    return const ApiException(ApiErrorType.offline, "You're offline");
  }
  return const ApiException(ApiErrorType.unknown, 'Something went wrong.');
}
