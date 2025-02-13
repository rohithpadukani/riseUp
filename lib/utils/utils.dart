import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Utils {
  String formatDateTime(DateTime dateTime) {
    return DateFormat('EEEE, MMM d, yyyy').format(dateTime);
  }
}

Color primaryGreen = const Color(0xff009B22);
