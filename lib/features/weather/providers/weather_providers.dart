import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/prefs_service.dart';
import '../../search/domain/city_result.dart';
import '../data/weather_api.dart';
import '../data/weather_repository.dart';
import '../domain/weather_models.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository(WeatherApi(ref.watch(dioProvider)));
});

/// The currently selected city. Loaded from (and saved to) local storage.
class SelectedCityNotifier extends Notifier<CityResult?> {
  @override
  CityResult? build() => ref.read(prefsServiceProvider).lastCity;

  Future<void> select(CityResult city) async {
    state = city;
    await ref.read(prefsServiceProvider).setLastCity(city);
  }
}

final selectedCityProvider =
    NotifierProvider<SelectedCityNotifier, CityResult?>(
        SelectedCityNotifier.new);

/// Forecast for the selected city as loading / data / error.
///
/// State is managed by hand (instead of a FutureProvider) so a failed
/// pull-to-refresh can keep the previous data on screen.
class WeatherNotifier extends Notifier<AsyncValue<WeatherData>> {
  int _generation = 0;

  @override
  AsyncValue<WeatherData> build() {
    final city = ref.watch(selectedCityProvider);
    final repository = ref.read(weatherRepositoryProvider);
    // Any in-flight request from an earlier build/dispose becomes stale.
    ref.onDispose(() => _generation++);
    if (city != null) {
      Future.microtask(() => _load(city, repository));
    }
    return const AsyncLoading();
  }

  /// Pull-to-refresh. Keeps existing data on failure and returns the error
  /// message (null on success) so the UI can show a snackbar.
  Future<String?> refresh() {
    final city = ref.read(selectedCityProvider);
    if (city == null) return Future.value(null);
    return _load(city, ref.read(weatherRepositoryProvider),
        keepDataOnError: true);
  }

  /// Retry from the error view: back to loading, then refetch.
  Future<void> retry() async {
    final city = ref.read(selectedCityProvider);
    if (city == null) return;
    final repository = ref.read(weatherRepositoryProvider);
    state = const AsyncLoading();
    await _load(city, repository);
  }

  Future<String?> _load(
    CityResult city,
    WeatherRepository repository, {
    bool keepDataOnError = false,
  }) async {
    final generation = ++_generation;
    try {
      final data = await repository.fetchWeather(city);
      if (generation != _generation) return null;
      state = AsyncData(data);
      return null;
    } on ApiException catch (e, st) {
      if (generation != _generation) return null;
      if (!(keepDataOnError && state.hasValue)) {
        state = AsyncError(e, st);
      }
      return e.message;
    } catch (_, st) {
      if (generation != _generation) return null;
      const fallback =
          ApiException(ApiErrorType.unknown, 'Something went wrong.');
      if (!(keepDataOnError && state.hasValue)) {
        state = AsyncError(fallback, st);
      }
      return fallback.message;
    }
  }
}

final weatherProvider =
    NotifierProvider<WeatherNotifier, AsyncValue<WeatherData>>(
        WeatherNotifier.new);
