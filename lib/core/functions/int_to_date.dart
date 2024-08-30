import 'package:intl/intl.dart';

String intToDate(int date,{bool withTime = false}) {
  return withTime?DateFormat('EEE,MMM dd, yyyy hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(date)): DateFormat('EEE,MMM dd, yyyy')
          .format(DateTime.fromMillisecondsSinceEpoch(date));
}