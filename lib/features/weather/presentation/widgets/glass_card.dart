import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';

/// Rounded, translucent, blurred card (plan.md section 4 "Card style").
///
/// The fill is chosen from the text colour in scope: dark text gets a light
/// fill, light text gets a dark fill, so cards stay visible on every
/// gradient. Set [blur] to false for small cards to save GPU work.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.blur = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final on = IconTheme.of(context).color ?? Colors.white;
    final darkText = on.computeLuminance() < 0.5;
    final fill = darkText
        ? Colors.white.withValues(alpha: 0.35)
        : Colors.black.withValues(alpha: 0.22);
    final radius = BorderRadius.circular(AppSpacing.cardRadius);

    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: Border.all(color: on.withValues(alpha: 0.2)),
      ),
      child: child,
    );

    return ClipRRect(
      borderRadius: radius,
      child: blur
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: box,
            )
          : box,
    );
  }
}
