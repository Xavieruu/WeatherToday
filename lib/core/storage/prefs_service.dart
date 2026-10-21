import 'dart:convert';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/search/domain/city_result.dart';
import '../utils/units.dart';

/// Overridden in main() with the real instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final prefsServiceProvider = Provider<PrefsService>((ref) {
  return PrefsService(ref.watch(sharedPreferencesProvider));
});

/// A forecast saved from an earlier successful download.
class CachedForecast {
  const CachedForecast(this.fetchedAt, this.data);

  final DateTime fetchedAt;
  final Map<String, dynamic> data;
}

class PrefsService {
  PrefsService(this._prefs);

  final SharedPreferences _prefs;

  static const _cachePrefix = 'forecast_cache_';
  static const _cacheIndexKey = 'forecast_cache_keys';
  static const _maxCached = 30;

  CachedForecast? readForecastCache(String cityKey) {
    final raw = _prefs.getString('$_cachePrefix$cityKey');
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic> &&
          decoded['data'] is Map<String, dynamic>) {
        final at = DateTime.tryParse(decoded['at'] as String? ?? '');
        if (at != null) {
          return CachedForecast(at, decoded['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {
      // Corrupt cache: ignore.
    }
    return null;
  }

  /// Saves the raw forecast JSON for a city. Keeps only the newest
  /// [_maxCached] cities so storage does not grow without limit.
  Future<void> writeForecastCache(
    String cityKey,
    Map<String, dynamic> data,
  ) async {
    await _prefs.setString(
      '$_cachePrefix$cityKey',
      jsonEncode({'at': DateTime.now().toIso8601String(), 'data': data}),
    );
    final keys = (_prefs.getStringList(_cacheIndexKey) ?? <String>[])
        .where((k) => k != cityKey)
        .toList()
      ..add(cityKey);
    while (keys.length > _maxCached) {
      await _prefs.remove('$_cachePrefix${keys.removeAt(0)}');
    }
    await _prefs.setStringList(_cacheIndexKey, keys);
  }

  static const _lastCityKey = 'last_city';
  static const _themeModeKey = 'theme_mode';
  static const _tempUnitKey = 'temp_unit';

  CityResult? get lastCity {
    final raw = _prefs.getString(_lastCityKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return CityResult.fromJson(decoded);
      }
    } catch (_) {
      // Corrupt data: treat as no saved city.
    }
    return null;
  }

  Future<void> setLastCity(CityResult city) async {
    await _prefs.setString(_lastCityKey, jsonEncode(city.toJson()));
  }

  static const _savedCitiesKey = 'saved_cities';

  List<CityResult> get savedCities {
    final raw = _prefs.getString(_savedCitiesKey);
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(CityResult.fromJson)
            .toList();
      }
    } catch (_) {
      // Corrupt data: start with an empty list.
    }
    return const [];
  }

  Future<void> setSavedCities(List<CityResult> cities) async {
    await _prefs.setString(
      _savedCitiesKey,
      jsonEncode(cities.map((c) => c.toJson()).toList()),
    );
  }

  ThemeMode get themeMode {
    switch (_prefs.getString(_themeModeKey)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.name);
  }

  TempUnit get tempUnit => _prefs.getString(_tempUnitKey) == 'fahrenheit'
      ? TempUnit.fahrenheit
      : TempUnit.celsius;

  Future<void> setTempUnit(TempUnit unit) async {
    await _prefs.setString(_tempUnitKey, unit.name);
  }
}
