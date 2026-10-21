import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/async_value_ext.dart';
import '../../../core/utils/page_routes.dart';
import '../../search/domain/city_result.dart';
import '../../search/presentation/city_search_screen.dart';
import '../../search/providers/saved_cities_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../domain/weather_code_mapper.dart';
import '../domain/weather_gradients.dart';
import '../domain/weather_models.dart';
import '../providers/weather_providers.dart';
import 'widgets/current_weather_header.dart';
import 'widgets/daily_forecast_card.dart';
import 'widgets/detail_cards.dart';
import 'widgets/error_view.dart';
import 'widgets/hourly_strip.dart';
import 'widgets/info_banners.dart';
import 'widgets/temperature_chart.dart';
import 'widgets/weather_skeleton.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Last gradient shown, kept while the next city loads so the background
  // doesn't flash to the fallback blue.
  List<Color>? _lastColors;

  @override
  void initState() {
    super.initState();
    // First launch (no saved city): go straight to City Search.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(selectedCityProvider) == null) _openSearch();
    });
  }

  void _openSearch() {
    Navigator.of(context).push(fadeSlideRoute<void>(const CitySearchScreen()));
  }

  void _openSettings() {
    Navigator.of(context).push(fadeSlideRoute<void>(const SettingsScreen()));
  }

  Future<void> _onRefresh() async {
    final error = await ref.read(weatherProvider.notifier).refresh();
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't refresh: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final city = ref.watch(selectedCityProvider);
    final weather = ref.watch(weatherProvider);
    final saved = ref.watch(savedCitiesProvider);
    final isSaved = city != null && saved.any((c) => c.key == city.key);
    // While a new city loads, show the skeleton rather than stale data.
    final data = weather.isLoading ? null : weather.safeValue;

    // Background gradient follows condition + day/night.
    var colors = _lastColors ?? WeatherGradients.fallback;
    if (data != null) {
      final info = weatherInfoFor(data.current.weatherCode);
      colors = WeatherGradients.colors(info.group, data.current.isDay);
      _lastColors = colors;
    }
    final onColor = WeatherGradients.onColor(colors);

    // Text and icons on Home use a color chosen for the gradient, not the
    // light/dark theme, so they stay readable.
    final base = Theme.of(context);
    final themed = base.copyWith(
      textTheme: base.textTheme.merge(AppTypography.textTheme(onColor)),
      iconTheme: IconThemeData(color: onColor),
    );
    final text = themed.textTheme;

    return AnimatedContainer(
      duration: AppDurations.gradient,
      curve: AppDurations.gradientCurve,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: Theme(
        data: themed,
        child: IconTheme(
          data: IconThemeData(color: onColor),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              foregroundColor: onColor,
              systemOverlayStyle: onColor == Colors.white
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
              titleSpacing: AppSpacing.screenPadding,
              title: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  city?.name ?? 'WeatherToday',
                  style: text.headlineMedium,
                  maxLines: 1,
                ),
              ),
              actions: [
                if (city != null)
                  IconButton(
                    tooltip: isSaved ? 'Remove from saved' : 'Save city',
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                    ),
                    onPressed: () =>
                        ref.read(savedCitiesProvider.notifier).toggle(city),
                  ),
                IconButton(
                  tooltip: 'Search city',
                  icon: const Icon(Icons.search),
                  onPressed: _openSearch,
                ),
                IconButton(
                  tooltip: 'Settings',
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: _openSettings,
                ),
              ],
            ),
            body: AnimatedSwitcher(
              duration: AppDurations.contentFade,
              switchInCurve: AppDurations.contentFadeCurve,
              child: _buildBody(city, weather, data),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    CityResult? city,
    AsyncValue<WeatherData> weather,
    WeatherData? data,
  ) {
    if (city == null) {
      return _EmptyCity(key: const ValueKey('empty'), onSearch: _openSearch);
    }
    if (data != null) {
      return _Content(
        key: const ValueKey('content'),
        city: city,
        data: data,
        onRefresh: _onRefresh,
      );
    }
    if (weather.hasError) {
      final error = weather.error;
      final apiError = error is ApiException ? error : null;
      return ErrorView(
        key: const ValueKey('error'),
        offline: apiError?.isOffline ?? false,
        message: apiError?.message ?? 'Something went wrong.',
        onRetry: () => ref.read(weatherProvider.notifier).retry(),
      );
    }
    return const WeatherSkeleton(key: ValueKey('loading'));
  }
}

class _Content extends StatelessWidget {
  const _Content({
    super.key,
    required this.city,
    required this.data,
    required this.onRefresh,
  });

  final CityResult city;
  final WeatherData data;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final rainMessage = rainAlertMessage(data.hourly);
    final localTime = DateFormat('EEE, h:mm a').format(data.cityNow);
    final updated = DateFormat('h:mm a').format(data.fetchedAt.toLocal());

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.sm,
          AppSpacing.screenPadding,
          AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          CurrentWeatherHeader(current: data.current, today: data.daily.first),
          Center(
            child: Text(
              'Local time $localTime  ·  Updated $updated',
              style: text.labelMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (data.isStale) ...[
            StaleBanner(fetchedAt: data.fetchedAt),
            const SizedBox(height: AppSpacing.cardGap),
          ],
          if (rainMessage != null) ...[
            RainAlertBanner(message: rainMessage),
            const SizedBox(height: AppSpacing.cardGap),
          ],
          HourlyStrip(items: data.hourly),
          const SizedBox(height: AppSpacing.cardGap),
          TemperatureChart(items: data.hourly),
          const SizedBox(height: AppSpacing.cardGap),
          DailyForecastCard(items: data.daily),
          const SizedBox(height: AppSpacing.cardGap),
          DetailCards(data: data, city: city),
        ],
      ),
    );
  }
}

class _EmptyCity extends StatelessWidget {
  const _EmptyCity({super.key, required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_city, size: 64),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Search for a city to see the weather',
              style: text.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.tonalIcon(
              onPressed: onSearch,
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}
