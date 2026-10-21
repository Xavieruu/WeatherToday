enum ApiErrorType { offline, server, malformed, unknown }

class ApiException implements Exception {
  const ApiException(this.type, this.message);

  final ApiErrorType type;
  final String message;

  bool get isOffline => type == ApiErrorType.offline;

  @override
  String toString() => 'ApiException($type): $message';
}
