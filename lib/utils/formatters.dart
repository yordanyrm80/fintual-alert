String money(double value) {
  final rounded = value.round();
  final raw = rounded.toString();
  final buffer = StringBuffer();

  for (var i = 0; i < raw.length; i++) {
    final fromEnd = raw.length - i;
    buffer.write(raw[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
  }

  return '\$${buffer.toString()}';
}

String shortDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String shortDateTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${shortDate(date)} $hour:$minute';
}
