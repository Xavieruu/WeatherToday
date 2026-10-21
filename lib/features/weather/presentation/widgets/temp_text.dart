import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/utils/units.dart';
import '../../../settings/providers/settings_providers.dart';

/// A temperature (given in °C) shown in the user's chosen unit.
/// Switching units cross-fades the text (200 ms, easeIn).
class TempText extends ConsumerWidget {
  const TempText(this.celsius, {super.key, this.style});

  final double celsius;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(temperatureUnitProvider);
    final text = unit.format(celsius);
    return AnimatedSwitcher(
      duration: AppDurations.unitSwitch,
      switchInCurve: AppDurations.unitSwitchCurve,
      child: Text(text, key: ValueKey<String>(text), style: style),
    );
  }
}
