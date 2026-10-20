# WeatherToday: Project Plan

## 1. Overview and goals

A simple, modern weather app built with Flutter (Dart) for Android, tested on a physical device. It shows current conditions, a 24-hour strip and a 7-day forecast for a searched city, using the free Open-Meteo API (no key). The UI uses Material 3 with glass-style cards and a gradient background that reflects weather and time of day. This is a solo project, so scope is locked to 12 features and built in small, device-runnable phases.

---

## 2. Feature list and acceptance criteria

| # | Feature | Acceptance criteria |
|---|---------|---------------------|
| 1 | Current weather | - Shows temperature, condition text, feels-like, and today's high/low<br>- Values match Open-Meteo for the same city<br>- Condition text matches the WMO code mapping |
| 2 | City search | - Typing 2+ characters shows up to 5 geocoding results (name, region, country)<br>- Tapping a result loads its weather and returns to Home<br>- Empty results show a "No cities found" message |
| 3 | Hourly forecast | - Horizontal strip of the next 24 hours starting at the current hour<br>- Each item shows time, icon, temperature<br>- Scrolls smoothly; times use the city's timezone |
| 4 | 7-day forecast | - 7 rows, each with weekday, icon, high/low<br>- First row labelled "Today"<br>- Units follow the °C/°F setting |
| 5 | Loading / error / offline | - Skeleton shimmer shown while loading<br>- API failure shows message + Retry button that refetches<br>- No network shows a distinct offline message + Retry |
| 6 | Dynamic gradient | - Background changes per condition group and day/night (`is_day`)<br>- Gradient transitions smoothly when city or condition changes<br>- Text stays readable on every gradient |
| 7 | Pull-to-refresh | - Pulling down on Home refetches data for the current city<br>- Indicator shows while refreshing<br>- On failure, previous data stays and a snackbar reports the error |
| 8 | Detail cards grid | - Cards for humidity, wind, UV index, pressure, visibility, sunrise/sunset<br>- Each shows value + unit + label<br>- Sunrise/sunset shown in city local time |
| 9 | Remember last city | - Selecting a city saves it<br>- Relaunching the app loads that city's weather directly<br>- First launch with no saved city opens City Search |
| 10 | Material 3 design | - Uses `useMaterial3: true` with a color seed<br>- Cards are rounded and glass-style (translucent + blur)<br>- One font family and the defined type scale throughout |
| 11 | Dark / light mode | - Follows system by default<br>- Settings toggle offers System / Light / Dark<br>- Choice persists across launches |
| 12 | °C / °F toggle | - Settings toggle switches all temperatures instantly (no refetch)<br>- Choice persists across launches<br>- Applies to current, hourly, daily, feels-like |

---

## 3. Screens and navigation

| Screen | Purpose | Widgets |
|--------|---------|---------|
| **Home** | Main weather view | Gradient background, app bar (city name, search icon, settings icon), `RefreshIndicator`, current weather header, hourly strip, 7-day list card, detail cards grid, skeleton / error / offline views |
| **City Search** | Find and pick a city | Search `TextField` (autofocus), results `ListView`, empty-state, loading indicator, error text |
| **Settings** | Preferences | Theme mode selector (System/Light/Dark), °C/°F segmented button |

```
App launch
   |
   +-- saved city? --yes--> Home <----> Settings
   |                          |
   +-- no ------------------> City Search
                              ^
Home --(search icon)----------+
City Search --(pick result)--> Home (pop with selected city)
```

---

## 4. UI and design spec

**Color seed:** `Color(0xFF3B82F6)` (blue). Used with `ColorScheme.fromSeed` for light and dark.

### Gradient mapping (condition group x day/night)

| Group (WMO codes) | Day | Night |
|-------------------|-----|-------|
| Clear (0) | `#4FACFE` to `#00C6FB` | `#0F2027` to `#2C5364` |
| Partly cloudy (1, 2) | `#6DA7E8` to `#A8C8F0` | `#1B2A49` to `#3A4A6B` |
| Overcast (3) | `#8E9EAB` to `#B8C4CE` | `#232B33` to `#3C4650` |
| Fog (45, 48) | `#BDC3C7` to `#DCE1E4` | `#2F3640` to `#4A525C` |
| Drizzle (51-57) | `#7F9DB5` to `#A9BFD0` | `#1F2D3A` to `#3A4B5A` |
| Rain (61-67, 80-82) | `#4B6C8C` to `#7A98B3` | `#141E30` to `#243B55` |
| Snow (71-77, 85, 86) | `#CFE3F1` to `#EAF2F8` | `#2B3A4F` to `#4E6580` |
| Thunderstorm (95, 96, 99) | `#3A3F58` to `#5C5F7A` | `#0B0C1A` to `#262A44` |

Hex values are starting points; tune on device for contrast.

### Typography (Google Fonts: Inter)

| Role | Size / weight | Used for |
|------|---------------|----------|
| Display | 72 / w300 | Current temperature |
| Headline | 28 / w600 | City name |
| Title | 18 / w600 | Card titles, condition text |
| Body | 16 / w400 | List rows |
| Label | 13 / w500 | Captions, units, hourly times |

### Card style
- Radius 24, translucent fill (white at 18% in light-on-gradient, black at 22% in dark), `BackdropFilter` blur sigma 12, 1px border at white 20% opacity, no hard shadow.

### Spacing (8-pt system)
- Tokens: 4, 8, 16, 24, 32. Screen horizontal padding 16. Gap between cards 16. Card inner padding 16.

### Animations

| What | Duration | Curve |
|------|----------|-------|
| Background gradient change (`AnimatedContainer`) | 600 ms | `easeInOut` |
| Content fade-in after load (`AnimatedSwitcher`) | 300 ms | `easeOut` |
| Shimmer skeleton loop | 1200 ms | linear |
| Screen transition Home <-> Search/Settings (fade + slight slide) | 250 ms | `easeOutCubic` |
| Unit toggle value change (`AnimatedSwitcher` on text) | 200 ms | `easeIn` |

---

## 5. Architecture

### Folder structure (feature-first)

```
lib/
  main.dart
  app.dart                     # MaterialApp, theme wiring
  core/
    constants/                 # spacing, durations
    theme/                     # app_theme.dart, typography
    network/                   # dio_client.dart, api_exception.dart
    storage/                   # prefs_service.dart
    utils/                     # unit conversion, date formatting, debouncer
  features/
    weather/
      data/                    # weather_api.dart, weather_repository.dart
      domain/                  # models, weather_code_mapper.dart
      presentation/            # home_screen.dart, widgets/
      providers/
    search/
      data/                    # geocoding_api.dart, geocoding_repository.dart
      domain/                  # city_result.dart
      presentation/            # city_search_screen.dart, widgets/
      providers/
    settings/
      presentation/            # settings_screen.dart
      providers/
```

### Data flow

```
Open-Meteo -> Dio API class -> Repository (parse to models, map errors)
           -> Riverpod provider (AsyncValue) -> UI (.when: loading/data/error)
```

### Providers

| Provider | Type | Responsibility |
|----------|------|----------------|
| `dioProvider` | `Provider<Dio>` | Configured Dio instance (timeouts) |
| `prefsProvider` | `FutureProvider<SharedPreferences>` (overridden in `main`) | Access to stored prefs |
| `weatherRepositoryProvider` | `Provider` | Forecast fetch + parsing |
| `geocodingRepositoryProvider` | `Provider` | City search fetch + parsing |
| `selectedCityProvider` | `NotifierProvider<City?>` | Current city; loads/saves last city |
| `weatherProvider` | `FutureProvider<WeatherData>` | Watches selected city; fetches forecast; `ref.invalidate` for refresh/retry |
| `citySearchProvider` | `NotifierProvider<AsyncValue<List<CityResult>>>` | Debounced search state |
| `themeModeProvider` | `NotifierProvider<ThemeMode>` | System/Light/Dark, persisted |
| `temperatureUnitProvider` | `NotifierProvider<TempUnit>` | C/F, persisted |

---

## 6. Data models

```dart
class CityResult {
  final int id;            // results[].id
  final String name;       // results[].name
  final double latitude;   // results[].latitude
  final double longitude;  // results[].longitude
  final String? country;   // results[].country
  final String? admin1;    // results[].admin1 (region/state)
  final String? timezone;  // results[].timezone
}

class CurrentWeather {
  final double temperature;          // current.temperature_2m
  final double apparentTemperature;  // current.apparent_temperature
  final int weatherCode;             // current.weather_code
  final bool isDay;                  // current.is_day (1/0)
  final int humidity;                // current.relative_humidity_2m
  final double windSpeed;            // current.wind_speed_10m
  final double pressure;             // current.pressure_msl
  final DateTime time;               // current.time
}

class HourlyItem {
  final DateTime time;       // hourly.time[i]
  final double temperature;  // hourly.temperature_2m[i]
  final int weatherCode;     // hourly.weather_code[i]
  final bool isDay;          // hourly.is_day[i]
}

class DailyItem {
  final DateTime date;       // daily.time[i]
  final int weatherCode;     // daily.weather_code[i]
  final double tempMax;      // daily.temperature_2m_max[i]
  final double tempMin;      // daily.temperature_2m_min[i]
  final DateTime sunrise;    // daily.sunrise[i]
  final DateTime sunset;     // daily.sunset[i]
}

class WeatherData {
  final CurrentWeather current;
  final List<HourlyItem> hourly;   // sliced to next 24 from current hour
  final List<DailyItem> daily;     // 7 items
  final double uvIndex;            // hourly.uv_index at current hour index
  final double visibility;         // hourly.visibility (metres) at current hour index
}
```

Note: `visibility` and `uv_index` are read from the hourly arrays at the index matching `current.time`. Details cards use today's `daily` sunrise/sunset.

---

## 7. API details

### Geocoding
`GET https://geocoding-api.open-meteo.com/v1/search`

| Param | Value |
|-------|-------|
| `name` | user query |
| `count` | `5` |
| `language` | `en` |
| `format` | `json` |

Sample response shape:
```json
{
  "results": [
    {
      "id": 1701668, "name": "Manila", "latitude": 14.6042, "longitude": 120.9822,
      "country": "Philippines", "country_code": "PH", "admin1": "Metro Manila",
      "timezone": "Asia/Manila"
    }
  ],
  "generationtime_ms": 0.9
}
```
When nothing matches, the `results` key is **absent** (treat as empty list).

### Forecast
`GET https://api.open-meteo.com/v1/forecast`

| Param | Value |
|-------|-------|
| `latitude`, `longitude` | from selected city |
| `current` | `temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,pressure_msl,wind_speed_10m` |
| `hourly` | `temperature_2m,weather_code,is_day,uv_index,visibility` |
| `daily` | `weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset` |
| `forecast_days` | `7` |
| `timezone` | `auto` |

Temperatures are fetched in °C (default) and converted client-side for °F. Wind in km/h (default), pressure in hPa, visibility in metres.

Sample response shape:
```json
{
  "latitude": 14.6, "longitude": 120.98, "timezone": "Asia/Manila",
  "current_units": { "temperature_2m": "°C", "wind_speed_10m": "km/h" },
  "current": {
    "time": "2026-10-20T13:45", "interval": 900,
    "temperature_2m": 31.2, "relative_humidity_2m": 64, "apparent_temperature": 36.0,
    "is_day": 1, "weather_code": 2, "pressure_msl": 1009.8, "wind_speed_10m": 11.4
  },
  "hourly": {
    "time": ["2026-10-20T00:00", "..."],
    "temperature_2m": [27.1, "..."], "weather_code": [1, "..."],
    "is_day": [0, "..."], "uv_index": [0.0, "..."], "visibility": [24140.0, "..."]
  },
  "daily": {
    "time": ["2026-10-20", "..."], "weather_code": [61, "..."],
    "temperature_2m_max": [32.5, "..."], "temperature_2m_min": [26.0, "..."],
    "sunrise": ["2026-10-20T05:51", "..."], "sunset": ["2026-10-20T17:30", "..."]
  }
}
```

### WMO code mapping (used for text, icon, gradient group)

| Code(s) | Condition | Group |
|---------|-----------|-------|
| 0 | Clear sky | Clear |
| 1, 2 | Mainly clear / Partly cloudy | Partly cloudy |
| 3 | Overcast | Overcast |
| 45, 48 | Fog / Rime fog | Fog |
| 51, 53, 55, 56, 57 | Drizzle (incl. freezing) | Drizzle |
| 61, 63, 65, 66, 67, 80, 81, 82 | Rain / Showers (incl. freezing rain) | Rain |
| 71, 73, 75, 77, 85, 86 | Snow / Snow grains / Snow showers | Snow |
| 95, 96, 99 | Thunderstorm (96/99 with hail) | Thunderstorm |

---

## 8. Error and edge-case handling

| Case | Handling |
|------|----------|
| No network (`DioExceptionType.connectionError` / timeouts) | Offline view: icon + "You're offline" + Retry; no extra connectivity package |
| API failure (non-200, 5xx) | Error view: friendly message + Retry (`ref.invalidate(weatherProvider)`) |
| Malformed data (missing keys, null values, length mismatch) | Repository catches parse errors and throws `ApiException.malformed`; shown as generic error with Retry |
| Empty search results (`results` absent) | "No cities found. Try a different name." |
| Query too short (<2 chars) | Do not call API; show hint text |
| Rapid repeated searches | 400 ms debounce on input; cancel the previous request with Dio `CancelToken`; ignore stale responses |
| Refresh failure with data on screen | Keep old data, show snackbar |
| Unknown WMO code | Fallback to "Unknown" condition + neutral cloud icon + Overcast gradient |
| Saved city missing/corrupt in prefs | Treat as no saved city; open City Search |
| Geocoding failure | Inline error in search screen with retry on next keystroke |

---

## 9. Dependencies

| Package | Reason |
|---------|--------|
| `flutter_riverpod` | State management with `AsyncValue` |
| `dio` | HTTP client, timeouts, cancel tokens |
| `shared_preferences` | Persist last city, theme mode, temperature unit |
| `shimmer` | Skeleton loading effect |
| `google_fonts` | Inter typography |
| `intl` | Format hours, weekdays, sunrise/sunset times |

`intl` is the only addition beyond your listed packages; it is needed for date/time formatting and is the standard choice. Icons use built-in Material icons (no icon package).

---

## 10. Phased build order

- [ ] **Phase 1: Setup + theme.** Create project, add dependencies, folder skeleton, Material 3 light/dark theme, Inter font, placeholder Home. *Runs on device: themed empty screen.*
- [ ] **Phase 2: API layer + models.** Dio client, geocoding + forecast API classes, models, WMO mapper, repository, error mapping. *Runs on device: debug screen printing parsed data for a hardcoded city.*
- [ ] **Phase 3: Home with current weather.** `selectedCityProvider`, `weatherProvider`, current weather header with loading/error/offline states. *Runs on device: real weather for a default city.*
- [ ] **Phase 4: City search + persistence.** Search screen with debounce, results, empty state, save/load last city. *Runs on device: search, pick, relaunch remembers city.*
- [ ] **Phase 5: Hourly + 7-day + detail cards.** Hourly strip, daily list, details grid. *Runs on device: full Home content.*
- [ ] **Phase 6: Dynamic gradient + glass cards.** Gradient mapping, glass card widget, transitions. *Runs on device: background reacts to condition and day/night.*
- [ ] **Phase 7: Settings.** Theme mode toggle, °C/°F toggle, persistence, apply units everywhere. *Runs on device: both toggles work and persist.*
- [ ] **Phase 8: Pull-to-refresh, polish, and testing.** Refresh indicator, shimmer skeleton, animation tuning, full device checklist. *Runs on device: release-quality build for testing.*

---

## 11. Testing checklist (physical Android device)

- [ ] First launch with no saved city opens City Search
- [ ] Search "Manila" returns up to 5 results; picking one loads Home
- [ ] Search gibberish shows "No cities found"
- [ ] Typing quickly sends few requests (debounce); no flicker of stale results
- [ ] Current temp, feels-like, high/low look correct against Open-Meteo or another source
- [ ] Hourly strip starts at current hour, shows 24 items, scrolls smoothly
- [ ] 7-day list shows 7 rows; first is "Today"
- [ ] All 6 detail cards show sensible values and units; sunrise/sunset in city local time
- [ ] Gradient differs for day vs night (compare a city currently in daytime vs nighttime)
- [ ] Gradient changes smoothly when switching cities
- [ ] Pull-to-refresh updates data; indicator appears and disappears
- [ ] Airplane mode on launch shows offline state; Retry works after reconnecting
- [ ] Airplane mode during pull-to-refresh keeps old data and shows snackbar
- [ ] Skeleton shimmer visible on slow load
- [ ] Kill and relaunch app: last city restored
- [ ] Theme: System follows device dark/light; manual Light/Dark override works and persists
- [ ] °C/°F toggle updates all temperatures instantly and persists after relaunch
- [ ] Text readable on all gradients in both light and dark mode
- [ ] No overflow errors with large system font size
- [ ] No crashes after rotating the device (or confirm portrait-only if locked)

---

## 12. Out of scope / Parking Lot

- GPS / current location
- Saved cities list
- Temperature chart
- Air quality
- Rain alerts
- Home screen widgets
- Multi-language
- iOS release
- Play Store publishing

**Rule: Nothing from this list gets built until all phases above are complete and tested.**

---

## Suggestions (not part of the plan; awaiting your decision)

1. **Cache last successful forecast** in `shared_preferences` so the offline state can show stale data with a "Last updated" label instead of an empty screen. Not in the 12 features, so it is not included.
2. **Lock to portrait orientation** to cut layout testing effort for a solo project.
