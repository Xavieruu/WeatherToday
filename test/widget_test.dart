import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_today/app.dart';

void main() {
  testWidgets('WeatherToday shows the initial weather screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WeatherApp()));

    expect(find.text('Weather'), findsOneWidget);
    expect(find.text('Phase 1: setup and theme'), findsOneWidget);
  });
}
