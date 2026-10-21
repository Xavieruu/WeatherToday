import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../data/geocoding_api.dart';
import '../data/geocoding_repository.dart';
import '../domain/city_result.dart';

final geocodingRepositoryProvider = Provider<GeocodingRepository>((ref) {
  return GeocodingRepository(GeocodingApi(ref.watch(dioProvider)));
});

class CitySearchState {
  const CitySearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.hasSearched = false,
  });

  final String query;
  final List<CityResult> results;
  final bool isLoading;
  final String? error;

  /// True once a request for [query] has finished (success or error).
  final bool hasSearched;
}

/// Debounced city search. Typing again cancels the pending timer and any
/// in-flight request; stale responses are ignored.
class CitySearchNotifier extends Notifier<CitySearchState> {
  static const _debounce = Duration(milliseconds: 400);

  Timer? _timer;
  CancelToken? _cancelToken;
  int _generation = 0;

  @override
  CitySearchState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _cancelToken?.cancel();
    });
    return const CitySearchState();
  }

  void reset() {
    _generation++;
    _timer?.cancel();
    _cancelToken?.cancel();
    state = const CitySearchState();
  }

  void onQueryChanged(String raw) {
    final query = raw.trim();
    final generation = ++_generation;
    _timer?.cancel();
    _cancelToken?.cancel();

    if (query.length < 2) {
      state = CitySearchState(query: query);
      return;
    }

    // Keep the previous results visible while the next request is pending.
    state = CitySearchState(
      query: query,
      results: state.results,
      isLoading: true,
    );
    _timer = Timer(_debounce, () => _search(query, generation));
  }

  Future<void> _search(String query, int generation) async {
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;
    try {
      final results = await ref
          .read(geocodingRepositoryProvider)
          .search(query, cancelToken: cancelToken);
      if (generation != _generation) return;
      state = CitySearchState(
        query: query,
        results: results,
        hasSearched: true,
      );
    } on ApiException catch (e) {
      if (generation != _generation) return;
      state = CitySearchState(
        query: query,
        error: e.isOffline
            ? "You're offline. Check your connection."
            : "Couldn't search right now. Try again.",
        hasSearched: true,
      );
    } catch (_) {
      if (generation != _generation) return;
      state = CitySearchState(
        query: query,
        error: "Couldn't search right now. Try again.",
        hasSearched: true,
      );
    }
  }
}

final citySearchProvider =
    NotifierProvider<CitySearchNotifier, CitySearchState>(
        CitySearchNotifier.new);
