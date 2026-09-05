import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

/// Format an integer-paise amount in whole rupees. The API contract keeps
/// money in minor units; display rounds exact paise down to whole rupees.
String formatMoney(int minor, String localeName) {
  final formatter = NumberFormat.currency(
    locale: localeName == 'hi' ? 'hi_IN' : 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  return formatter.format(minor / 100);
}

String formatExactMoney(int minor, String localeName) {
  final formatter = NumberFormat.currency(
    locale: localeName == 'hi' ? 'hi_IN' : 'en_IN',
    symbol: '₹',
    decimalDigits: minor % 100 == 0 ? 0 : 2,
  );
  return formatter.format(minor / 100);
}

String formatCompactMoney(int minor, String localeName) {
  final formatter = NumberFormat.compactCurrency(
    locale: localeName == 'hi' ? 'hi_IN' : 'en_IN',
    symbol: '₹',
    decimalDigits: 1,
  );
  return formatter.format(minor / 100);
}

String formatRupeeDecimal(Decimal value, String localeName) {
  return formatMoney((value * Decimal.fromInt(100)).round().toBigInt().toInt(), localeName);
}

String formatDateTime(DateTime value, String localeName) {
  return DateFormat('d MMM, h:mm a', localeName == 'hi' ? 'hi_IN' : 'en_IN')
      .format(value.toLocal());
}

/// Convert a rupee text field into integer paise without binary floats.
int parseMinor(String value) {
  final parsed = Decimal.tryParse(value.trim());
  if (parsed == null) return 0;
  return (parsed * Decimal.fromInt(100)).round().toBigInt().toInt();
}

/// Convert integer paise back into an editable rupee string.
String minorToInput(int minor) {
  final sign = minor < 0 ? '-' : '';
  final absolute = minor.abs();
  final rupees = absolute ~/ 100;
  final paise = absolute % 100;
  if (paise == 0) return '$sign$rupees';
  return '$sign$rupees.${paise.toString().padLeft(2, '0')}';
}
