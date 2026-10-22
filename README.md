# WeatherToday

A simple, modern weather app for Android, built with Flutter. It shows current conditions, an hourly strip, a temperature chart, a 7-day forecast and detailed readings for any city, using the free [Open-Meteo](https://open-meteo.com/) API (no API key needed).

## Features

**Weather**
- Current temperature, condition, feels-like, and today's high/low
- Next 24 hours (scrollable) with rain chance per hour
- 24-hour temperature chart
- 7-day forecast with rain chance
- Detail tiles: humidity, wind (with direction), rain chance, UV index, air quality (US AQI), pressure, visibility, sunrise/sunset
- City's local time and last-updated time
- In-app rain banner when rain is likely (50%+) in the next 4 hours

**Places**
- Search any city or place (debounced, up to 5 results)
- Popular cities shown as suggestions
- Save cities with a bookmark; the Saved list shows each city's current temperature
- "Use my location" (GPS)
- The last viewed city is remembered between launches

**Experience**
- Gradient background that changes with the weather and day/night
- Glass-style cards, Material 3 design, Inter font
- Light / dark / system theme and °C / °F toggle (both remembered)
- Skeleton loading, error and offline states with Retry
- Pull-to-refresh; if an update fails, the last saved forecast is shown with a "saved data" banner

## Tech stack

| Area | Choice |
|------|--------|
| Framework | Flutter (Dart), Android target |
| State management | Riverpod (`flutter_riverpod`) |
| HTTP | `dio` |
| Local storage | `shared_preferences` |
| Charts | `fl_chart` |
| Location | `geolocator` |
| UI helpers | `shimmer`, `google_fonts`, `intl` |
| Data | Open-Meteo forecast, geocoding and air-quality APIs |

## Getting started

**Requirements:** Flutter SDK (stable) with the Android toolchain (check with `flutter doctor`) and an Android phone or emulator.

```bash
flutter pub get
flutter run
```

**Android permissions.** "Use my location" needs these lines in `android/app/src/main/AndroidManifest.xml`, just above `<application`:

```xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

Internet access is added by Flutter's debug configuration; for release builds make sure `android.permission.INTERNET` is also present.

**Run on a phone.** Turn on Developer options, enable USB debugging, plug the phone in and check that `flutter devices` lists it. After the first install, press `r` in the terminal for hot reload. Changes to `pubspec.yaml`, the manifest or icons need a full `flutter run`.

## Tests

```bash
flutter analyze
flutter test
```

`test/weather_logic_test.dart` covers unit conversion, compass/AQI/UV helpers, weather-code mapping, city matching and forecast JSON parsing (including missing and malformed data). `test/widget_test.dart` checks that a first launch with no saved city opens City Search.

## Project structure

```
lib/
  main.dart                 # starts the app with local storage ready
  app.dart                  # MaterialApp, theme mode
  core/
    constants/              # spacing, animation durations
    network/                # Dio client, error mapping
    storage/                # shared_preferences wrapper, forecast cache
    theme/                  # Material 3 theme, type scale
    utils/                  # units, formatting helpers, page transitions
  features/
    weather/                # Home screen, models, API, repository, providers
    search/                 # City Search, saved cities, location, popular list
    settings/               # theme and temperature unit
test/
plan.md                     # full project plan and feature acceptance criteria
```

Data flows one way: Open-Meteo, then the API class, then the repository (parsing, caching, error mapping), then a Riverpod provider, then the UI.

## Data and attribution

Weather, geocoding and air-quality data come from [Open-Meteo](https://open-meteo.com/), which is free for non-commercial use under CC BY 4.0 and requires attribution. Keep this credit if you publish the app. Popular cities are a hand-picked list, not live "most searched" statistics.

## Known limitations

- Android only; iOS has not been set up or tested.
- No home screen widget and no background rain notifications (the rain alert is an in-app banner only).
- "My location" shows as "My location" rather than a place name (Open-Meteo has no reverse geocoding).
- Air quality is shown only when the air-quality service responds.

## Troubleshooting

- **`INSTALL_FAILED_USER_RESTRICTED` on Xiaomi/POCO phones:** in Developer options enable *Install via USB* (and *USB debugging (Security settings)* if shown), keep the screen unlocked and tap Install on the phone when prompted. Turning off MIUI/HyperOS optimization and rebooting also helps.
- **Phone not listed by `flutter devices`:** try another cable (many are charge-only), set USB mode to File transfer, accept the debugging prompt, and on Fedora install `android-tools`.
- **`adb: more than one device/emulator`:** use `adb -s <device-id> ...` or close the emulator.

## Project plan

See [`plan.md`](plan.md) for the original scope, screens, UI spec, architecture, API details, phased build order, testing checklist and the parking lot of ideas not yet built.