import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double amount, {String currency = 'USD'}) {
    final format = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
      locale: 'es',
    );
    return format.format(amount);
  }

  static String formatDate(DateTime date) {
    final format = DateFormat('dd/MM/yyyy');
    return format.format(date);
  }

  static String formatDateForDisplay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return 'Hoy';
    } else if (dateDay == yesterday) {
      return 'Ayer';
    } else {
      return formatDate(date);
    }
  }

  static String formatDateTime(DateTime date) {
    final format = DateFormat('dd/MM/yyyy HH:mm');
    return format.format(date);
  }
}