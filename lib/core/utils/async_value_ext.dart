import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Null-safe access to an AsyncValue's data that behaves the same on every
/// Riverpod version (`value` throws on errors in 2.x, returns null in 3.x).
extension SafeAsyncValue<T> on AsyncValue<T> {
  T? get safeValue => hasValue ? requireValue : null;
}
