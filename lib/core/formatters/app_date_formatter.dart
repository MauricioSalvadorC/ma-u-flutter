class AppDateFormatter {
  const AppDateFormatter._();

  static String date(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  static String time(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String dateTime(DateTime value) {
    return '${date(value)} ${time(value)}';
  }

  static String dateWithOptionalTime(DateTime value) {
    if (value.hour == 0 && value.minute == 0) {
      return date(value);
    }

    return dateTime(value);
  }
}
