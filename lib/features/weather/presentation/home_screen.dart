import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';

/// Phase 1 placeholder. Shows the type scale and a card so the theme can be
/// checked on a device. Replaced by the real Home screen in Phase 3.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text('Weather', style: text.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('Phase 1: setup and theme', style: text.labelMedium),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('24°', style: text.displayLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Partly cloudy', style: text.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Feels like 27°', style: text.bodyLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text('H 28°  L 22°', style: text.labelMedium),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
