import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/weather/presentation/home_screen.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Follows the system for now; the manual toggle arrives in Phase 7.
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
