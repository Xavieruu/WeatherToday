import 'city_result.dart';

/// Hand-picked well-known places shown as suggestions in City Search.
/// (Open-Meteo has no "most searched" data, so this list is curated.)
/// Ids are negative so they never clash with real geocoding ids.
const List<CityResult> popularCities = [
  CityResult(
    id: -1, name: 'Manila', admin1: 'Metro Manila', country: 'Philippines',
    latitude: 14.6042, longitude: 120.9822, timezone: 'Asia/Manila',
  ),
  CityResult(
    id: -2, name: 'Cebu City', admin1: 'Central Visayas', country: 'Philippines',
    latitude: 10.3167, longitude: 123.8907, timezone: 'Asia/Manila',
  ),
  CityResult(
    id: -3, name: 'Davao', admin1: 'Davao Region', country: 'Philippines',
    latitude: 7.0731, longitude: 125.6128, timezone: 'Asia/Manila',
  ),
  CityResult(
    id: -4, name: 'Tokyo', admin1: 'Tokyo', country: 'Japan',
    latitude: 35.6895, longitude: 139.6917, timezone: 'Asia/Tokyo',
  ),
  CityResult(
    id: -5, name: 'Seoul', country: 'South Korea',
    latitude: 37.5665, longitude: 126.9780, timezone: 'Asia/Seoul',
  ),
  CityResult(
    id: -6, name: 'Singapore', country: 'Singapore',
    latitude: 1.2897, longitude: 103.8501, timezone: 'Asia/Singapore',
  ),
  CityResult(
    id: -7, name: 'Bangkok', country: 'Thailand',
    latitude: 13.7563, longitude: 100.5018, timezone: 'Asia/Bangkok',
  ),
  CityResult(
    id: -8, name: 'Dubai', admin1: 'Dubai', country: 'United Arab Emirates',
    latitude: 25.2048, longitude: 55.2708, timezone: 'Asia/Dubai',
  ),
  CityResult(
    id: -9, name: 'London', admin1: 'England', country: 'United Kingdom',
    latitude: 51.5085, longitude: -0.1257, timezone: 'Europe/London',
  ),
  CityResult(
    id: -10, name: 'Paris', admin1: 'Île-de-France', country: 'France',
    latitude: 48.8534, longitude: 2.3488, timezone: 'Europe/Paris',
  ),
  CityResult(
    id: -11, name: 'New York', admin1: 'New York', country: 'United States',
    latitude: 40.7143, longitude: -74.0060, timezone: 'America/New_York',
  ),
  CityResult(
    id: -12, name: 'Los Angeles', admin1: 'California', country: 'United States',
    latitude: 34.0522, longitude: -118.2437, timezone: 'America/Los_Angeles',
  ),
  CityResult(
    id: -13, name: 'Sydney', admin1: 'New South Wales', country: 'Australia',
    latitude: -33.8678, longitude: 151.2073, timezone: 'Australia/Sydney',
  ),
];
