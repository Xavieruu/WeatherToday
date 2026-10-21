import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/units.dart';
import '../../settings/providers/settings_providers.dart';
import '../../weather/domain/weather_code_mapper.dart';
import '../../weather/providers/weather_providers.dart';
import '../data/location_service.dart';
import '../domain/city_result.dart';
import '../domain/popular_cities.dart';
import '../providers/saved_cities_provider.dart';
import '../providers/search_providers.dart';

class CitySearchScreen extends ConsumerStatefulWidget {
  const CitySearchScreen({super.key});

  @override
  ConsumerState<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends ConsumerState<CitySearchScreen> {
  final _controller = TextEditingController();
  bool _locating = false;

  Future<void> _useMyLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final place = await ref.read(locationServiceProvider).current();
      if (!mounted) return;
      _pick(place);
    } on LocationException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage("Couldn't get your location.");
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    // Start every visit with a clean slate.
    Future.microtask(() {
      if (mounted) ref.read(citySearchProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pick(CityResult city) {
    ref.read(selectedCityProvider.notifier).select(city);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(citySearchProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          style: text.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search city or country',
            border: InputBorder.none,
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _controller.clear();
                    ref.read(citySearchProvider.notifier).onQueryChanged('');
                  },
                );
              },
            ),
          ),
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          onChanged: ref.read(citySearchProvider.notifier).onQueryChanged,
        ),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _message(BuildContext context, String message, {IconData? icon}) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 48),
              const SizedBox(height: AppSpacing.md),
            ],
            Text(message, style: text.bodyLarge, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  /// One row: tap to open the city, bookmark to save / unsave it.
  Widget _cityTile(CityResult city, {required bool saved}) {
    return ListTile(
      leading: const Icon(Icons.place_outlined),
      title: Text(city.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: city.subtitle.isEmpty
          ? null
          : Text(city.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        tooltip: saved ? 'Remove from saved' : 'Save city',
        icon: Icon(
          saved ? Icons.bookmark : Icons.bookmark_border,
          color: saved ? Theme.of(context).colorScheme.primary : null,
        ),
        onPressed: () => ref.read(savedCitiesProvider.notifier).toggle(city),
      ),
      onTap: () => _pick(city),
    );
  }

  Widget _sectionHeader(String title) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(title, style: text.titleMedium),
    );
  }

  /// Shown when the search box is empty: saved cities, then popular ones.
  Widget _suggestions(BuildContext context) {
    final saved = ref.watch(savedCitiesProvider);
    final savedKeys = saved.map((c) => c.key).toSet();
    final text = Theme.of(context).textTheme;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        ListTile(
          leading: _locating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          title: const Text('Use my location'),
          onTap: _useMyLocation,
        ),
        _sectionHeader('Saved'),
        if (saved.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              'Tap the bookmark on any city to save it here.',
              style: text.bodyLarge,
            ),
          )
        else
          for (final city in saved)
            _SavedCityTile(
              city: city,
              onTap: () => _pick(city),
              onUnsave: () =>
                  ref.read(savedCitiesProvider.notifier).toggle(city),
            ),
        _sectionHeader('Popular'),
        for (final city in popularCities)
          _cityTile(city, saved: savedKeys.contains(city.key)),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildBody(BuildContext context, CitySearchState state) {
    if (state.query.length < 2) {
      return _suggestions(context);
    }
    if (state.error != null && state.results.isEmpty) {
      return _message(context, state.error!, icon: Icons.error_outline);
    }
    if (state.isLoading && state.results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.hasSearched && state.results.isEmpty) {
      return _message(context, 'No places found. Try a different name.',
          icon: Icons.location_off_outlined);
    }

    final savedKeys = ref.watch(savedCitiesProvider).map((c) => c.key).toSet();

    return Column(
      children: [
        if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final city = state.results[index];
              return _cityTile(city, saved: savedKeys.contains(city.key));
            },
          ),
        ),
      ],
    );
  }
}

/// A saved city with its current temperature and condition.
class _SavedCityTile extends ConsumerWidget {
  const _SavedCityTile({
    required this.city,
    required this.onTap,
    required this.onUnsave,
  });

  final CityResult city;
  final VoidCallback onTap;
  final VoidCallback onUnsave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(cityWeatherProvider(city));
    final unit = ref.watch(temperatureUnitProvider);
    final text = Theme.of(context).textTheme;

    final Widget live = weather.when(
      data: (data) {
        if (data == null) return Text('—', style: text.titleMedium);
        final info = weatherInfoFor(data.current.weatherCode);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(info.icon(data.current.isDay), size: 20),
            const SizedBox(width: AppSpacing.xs),
            Text(unit.format(data.current.temperature),
                style: text.titleMedium),
          ],
        );
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (e, s) => Text('—', style: text.titleMedium),
    );

    return ListTile(
      leading: const Icon(Icons.bookmark),
      title: Text(city.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: city.subtitle.isEmpty
          ? null
          : Text(city.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          live,
          IconButton(
            tooltip: 'Remove from saved',
            icon: const Icon(Icons.close),
            onPressed: onUnsave,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
