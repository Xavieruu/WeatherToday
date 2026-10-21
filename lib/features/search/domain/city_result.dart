/// A geocoding result from Open-Meteo (`results[]`).
class CityResult {
  const CityResult({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
    this.timezone,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1;
  final String? timezone;

  factory CityResult.fromJson(Map<String, dynamic> json) {
    return CityResult(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'country': country,
        'admin1': admin1,
        'timezone': timezone,
      };

  /// Identity used to tell places apart (saved list, popular list, results).
  /// Rounded coordinates, so the same place from different sources matches.
  String get key =>
      '${latitude.toStringAsFixed(2)},${longitude.toStringAsFixed(2)}';

  // Two results for the same place are equal, so they can be used as
  // provider family arguments and compared in lists.
  @override
  bool operator ==(Object other) => other is CityResult && other.key == key;

  @override
  int get hashCode => key.hashCode;

  /// "Region, Country" line shown under the city name.
  String get subtitle => [admin1, country]
      .whereType<String>()
      .where((s) => s.isNotEmpty)
      .join(', ');
}
