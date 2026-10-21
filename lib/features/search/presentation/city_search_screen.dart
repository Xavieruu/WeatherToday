import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../weather/providers/weather_providers.dart';
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
          decoration: const InputDecoration(
            hintText: 'Search city or country',
            border: InputBorder.none,
          ),
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
      title: Text(city.name),
      subtitle: city.subtitle.isEmpty ? null : Text(city.subtitle),
      trailing: IconButton(
        tooltip: saved ? 'Remove from saved' : 'Save city',
        icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
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
      children: [
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
          for (final city in saved) _cityTile(city, saved: true),
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
