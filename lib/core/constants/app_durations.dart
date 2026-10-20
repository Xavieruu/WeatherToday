import 'package:flutter/animation.dart';

/// Animation timings and curves (see plan.md section 4).
class AppDurations {
  AppDurations._();

  static const Duration gradient = Duration(milliseconds: 600);
  static const Curve gradientCurve = Curves.easeInOut;

  static const Duration contentFade = Duration(milliseconds: 300);
  static const Curve contentFadeCurve = Curves.easeOut;

  static const Duration shimmer = Duration(milliseconds: 1200);

  static const Duration screenTransition = Duration(milliseconds: 250);
  static const Curve screenTransitionCurve = Curves.easeOutCubic;

  static const Duration unitSwitch = Duration(milliseconds: 200);
  static const Curve unitSwitchCurve = Curves.easeIn;
}
