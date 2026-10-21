import 'package:flutter/material.dart';

import '../constants/app_durations.dart';

/// Fade + slight upward slide, 250 ms, easeOutCubic (plan.md section 4).
Route<T> fadeSlideRoute<T>(Widget page) {
  final curve = CurveTween(curve: AppDurations.screenTransitionCurve);
  final slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero);

  return PageRouteBuilder<T>(
    transitionDuration: AppDurations.screenTransition,
    reverseTransitionDuration: AppDurations.screenTransition,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = animation.drive(curve);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(position: curved.drive(slide), child: child),
      );
    },
  );
}
