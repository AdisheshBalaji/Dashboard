import 'package:intl/intl.dart';

String formatDate(int timestamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  DateTime now = DateTime.now();

  if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
    return "Today ${DateFormat('h:mma').format(dateTime).toLowerCase()}";
  } else {
    return DateFormat('MMMM d, yyyy').format(dateTime);
  }
}
