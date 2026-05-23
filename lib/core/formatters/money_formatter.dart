class MoneyFormatter {
  const MoneyFormatter._();

  static String pesos(int cents) {
    final value = cents ~/ 100;
    final text = value.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      final remaining = text.length - i;
      buffer.write(text[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }

    return '\$${buffer.toString()}';
  }
}
