import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale from plan.md section 4 (Inter).
///
/// Role -> TextTheme slot:
///   Display  72 / w300 -> displayLarge   (current temperature)
///   Headline 28 / w600 -> headlineMedium (city name)
///   Title    18 / w600 -> titleMedium    (card titles, condition text)
///   Body     16 / w400 -> bodyLarge      (list rows)
///   Label    13 / w500 -> labelMedium    (captions, units, hourly times)
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color color) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 72,
        fontWeight: FontWeight.w300,
        color: color,
        height: 1.0,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }
}
