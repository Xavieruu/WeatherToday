/// 8-point compass label for a wind direction in degrees
/// (Open-Meteo `wind_direction_10m` is where the wind comes FROM).
String compassDirection(num degrees) {
  const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  final index = ((degrees.toDouble() % 360) / 45).round() % 8;
  return dirs[index];
}

/// Description of a US AQI value.
String aqiLabel(num aqi) {
  if (aqi <= 50) return 'Good';
  if (aqi <= 100) return 'Moderate';
  if (aqi <= 150) return 'Unhealthy for sensitive groups';
  if (aqi <= 200) return 'Unhealthy';
  if (aqi <= 300) return 'Very unhealthy';
  return 'Hazardous';
}

/// Description of a UV index value.
String uvLabel(num uv) {
  if (uv < 3) return 'Low';
  if (uv < 6) return 'Moderate';
  if (uv < 8) return 'High';
  if (uv < 11) return 'Very high';
  return 'Extreme';
}
