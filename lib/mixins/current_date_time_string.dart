import 'package:intl/intl.dart';

mixin CurrentDateTimeString {
  String getCurrentDateTimeString({String format = "yyyy-MM-dd HH:mm:ss"}) {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat(format);
    return formatter.format(now);
  }
}