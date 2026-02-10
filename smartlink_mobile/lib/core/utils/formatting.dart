import 'package:intl/intl.dart';

class Formatting {
  static String naira(num amount, {int decimalDigits = 2}) {
    return NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  static String shortDateTime(DateTime value) {
    return DateFormat('d MMM, HH:mm').format(value);
  }
}

