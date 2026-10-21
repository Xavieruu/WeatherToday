import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../weather/providers/weather_providers.dart';
import '../domain/city_result.dart';
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
            hintText: 'Search city',
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

  Widget _buildBody(BuildContext context, CitySearchState state) {
    if (state.query.length < 2) {
      return _message(context, 'Type at least 2 characters to search.',
          icon: Icons.search);
    }
    if (state.error != null && state.results.isEmpty) {
      return _message(context, state.error!, icon: Icons.error_outline);
    }
    if (state.isLoading && state.results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.hasSearched && state.results.isEmpty) {
      return _message(context, 'No cities found. Try a different name.',
          icon: Icons.location_off_outlined);
    }

    return Column(
      children: [
        if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: ListView.builder(
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final city = state.results[index];
              return ListTile(
                leading: const Icon(Icons.place_outlined),
                title: Text(city.name),
                subtitle: city.subtitle.isEmpty ? null : Text(city.subtitle),
                onTap: () => _pick(city),
              );
            },
          ),
        ),
      ],
    );
  }
}
