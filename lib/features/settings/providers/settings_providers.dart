import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/prefs_service.dart';
import '../../../core/utils/units.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.read(prefsServiceProvider).themeMode;

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(prefsServiceProvider).setThemeMode(mode);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class TemperatureUnitNotifier extends Notifier<TempUnit> {
  @override
  TempUnit build() => ref.read(prefsServiceProvider).tempUnit;

  Future<void> set(TempUnit unit) async {
    state = unit;
    await ref.read(prefsServiceProvider).setTempUnit(unit);
  }
}

final temperatureUnitProvider =
    NotifierProvider<TemperatureUnitNotifier, TempUnit>(
        TemperatureUnitNotifier.new);
