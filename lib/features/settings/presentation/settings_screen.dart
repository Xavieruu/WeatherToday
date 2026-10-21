import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/units.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final mode = ref.watch(themeModeProvider);
    final unit = ref.watch(temperatureUnitProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text('Appearance', style: text.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {mode},
            onSelectionChanged: (selection) =>
                ref.read(themeModeProvider.notifier).set(selection.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Temperature unit', style: text.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<TempUnit>(
            segments: const [
              ButtonSegment(value: TempUnit.celsius, label: Text('°C')),
              ButtonSegment(value: TempUnit.fahrenheit, label: Text('°F')),
            ],
            selected: {unit},
            onSelectionChanged: (selection) => ref
                .read(temperatureUnitProvider.notifier)
                .set(selection.first),
          ),
        ],
      ),
    );
  }
}
