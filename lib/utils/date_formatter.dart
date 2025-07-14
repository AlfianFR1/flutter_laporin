import 'package:intl/intl.dart';

class DateFormatter {
  static String formatIndonesia(DateTime dateTime) {
    final formatter = DateFormat('HH:mm - dd MMMM yyyy', 'id_ID');
    return formatter.format(dateTime.toLocal());
  }

  static String fromIso(String isoDateString) {
    final dateTime = DateTime.parse(isoDateString);
    return formatIndonesia(dateTime);
  }

  static String formatShort(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy', 'id_ID').format(dateTime.toLocal());
}

}
