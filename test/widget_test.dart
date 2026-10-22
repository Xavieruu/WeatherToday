import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_today/app.dart';
import 'package:weather_today/core/storage/prefs_service.dart';

void main() {
  testWidgets('first launch with no saved city opens City Search',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const WeatherApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Use my location'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
  });
}