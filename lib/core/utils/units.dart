enum TempUnit { celsius, fahrenheit }

extension TempUnitX on TempUnit {
  String get symbol => this == TempUnit.celsius ? '°C' : '°F';

  /// Converts a Celsius value (as returned by Open-Meteo) to this unit.
  double convert(double celsius) =>
      this == TempUnit.celsius ? celsius : celsius * 9 / 5 + 32;

  /// Rounded value with a degree sign, e.g. "24°".
  String format(double celsius) => '${convert(celsius).round()}°';
}
