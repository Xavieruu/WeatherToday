import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/async_value_ext.dart';
import '../../../core/utils/page_routes.dart';
import '../../search/domain/city_result.dart';
import '../../search/presentation/city_search_screen.dart';
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
import 'widgets/weather_skeleton.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
    // While a new city loads, show the skeleton rather than stale data.
    final data = weather.isLoading ? null : weather.safeValue;

    // Background gradient follows condition + day/night.
    var colors = WeatherGradients.fallback;
    if (data != null) {
      final info = weatherInfoFor(data.current.weatherCode);
      colors = WeatherGradients.colors(info.group, data.current.isDay);
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
              title: Text(
                city?.name ?? 'WeatherToday',
                style: text.headlineMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
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
  const _Content({super.key, required this.data, required this.onRefresh});

  final WeatherData data;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.sm,
          AppSpacing.screenPadding,
          AppSpacing.xl,
        ),
        children: [
          CurrentWeatherHeader(current: data.current, today: data.daily.first),
          const SizedBox(height: AppSpacing.lg),
          HourlyStrip(items: data.hourly),
          const SizedBox(height: AppSpacing.cardGap),
          DailyForecastCard(items: data.daily),
          const SizedBox(height: AppSpacing.cardGap),
          DetailCards(data: data),
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
