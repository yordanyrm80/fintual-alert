double parseNumber(String value) {
  final clean = value.replaceAll(',', '.').trim();
  return double.tryParse(clean) ?? 0;
}

double readDouble(Object? value, double fallback) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

double roundToHundreds(double value) => (value / 100).round() * 100;
