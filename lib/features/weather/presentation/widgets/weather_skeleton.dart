import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_spacing.dart';

/// Shimmering placeholder that mirrors the Home layout while loading.
class WeatherSkeleton extends StatelessWidget {
  const WeatherSkeleton({super.key});

  Widget _box({double? width, required double height, double radius = 16}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = _box(height: 110, radius: AppSpacing.cardRadius);
    final tile = Expanded(
      child: _box(height: 96, radius: AppSpacing.cardRadius),
    );

    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.22),
      highlightColor: Colors.white.withValues(alpha: 0.45),
      period: AppDurations.shimmer,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.md,
          AppSpacing.screenPadding,
          AppSpacing.xl,
        ),
        children: [
          Center(child: _box(width: 64, height: 64, radius: 32)),
          const SizedBox(height: AppSpacing.md),
          Center(child: _box(width: 160, height: 72)),
          const SizedBox(height: AppSpacing.md),
          Center(child: _box(width: 120, height: 20)),
          const SizedBox(height: AppSpacing.lg),
          card,
          const SizedBox(height: AppSpacing.cardGap),
          _box(height: 300, radius: AppSpacing.cardRadius),
          const SizedBox(height: AppSpacing.cardGap),
          Row(children: [
            tile,
            const SizedBox(width: AppSpacing.cardGap),
            tile,
          ]),
          const SizedBox(height: AppSpacing.cardGap),
          Row(children: [
            tile,
            const SizedBox(width: AppSpacing.cardGap),
            tile,
          ]),
        ],
      ),
    );
  }
}
