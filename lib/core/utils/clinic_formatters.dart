import 'package:intl/intl.dart';

class ClinicFormatters {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'ar_EG',
    symbol: 'ج.م',
    decimalDigits: 0,
  );
  static final DateFormat _shortDate = DateFormat('dd/MM/yyyy', 'ar');
  static final DateFormat _longDate = DateFormat('dd MMM yyyy', 'ar');
  static final DateFormat _dateTime = DateFormat('dd MMM - HH:mm', 'ar');
  static final DateFormat _monthLabel = DateFormat('MMM', 'ar');
  static final DateFormat _dayLabel = DateFormat('E', 'ar');

  static String formatCurrency(double value) => _currency.format(value);

  static String formatDate(DateTime value) => _shortDate.format(value);

  static String formatLongDate(DateTime value) => _longDate.format(value);

  static String formatDateTime(DateTime value) => _dateTime.format(value);

  static String monthLabel(DateTime value) => _monthLabel.format(value);

  static String weekdayLabel(DateTime value) => _dayLabel.format(value);

  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    final hasNotHadBirthday =
        now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day);
    if (hasNotHadBirthday) {
      age--;
    }
    return age;
  }

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month);

  static DateTime startOfYear(DateTime date) => DateTime(date.year);

  static DateTime startOfWeek(DateTime date) {
    final dayStart = startOfDay(date);
    final difference = dayStart.weekday % 7;
    return dayStart.subtract(Duration(days: difference));
  }
}
