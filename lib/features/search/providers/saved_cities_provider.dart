import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/prefs_service.dart';
import '../domain/city_result.dart';

/// Cities the user saved to check regularly. Persisted locally.
class SavedCitiesNotifier extends Notifier<List<CityResult>> {
  @override
  List<CityResult> build() => ref.read(prefsServiceProvider).savedCities;

  bool contains(CityResult city) => state.any((c) => c.key == city.key);

  /// Saves the city if it isn't saved yet, otherwise removes it.
  Future<void> toggle(CityResult city) async {
    final next = contains(city)
        ? state.where((c) => c.key != city.key).toList()
        : [...state, city];
    state = next;
    await ref.read(prefsServiceProvider).setSavedCities(next);
  }
}

final savedCitiesProvider =
    NotifierProvider<SavedCitiesNotifier, List<CityResult>>(
        SavedCitiesNotifier.new);
