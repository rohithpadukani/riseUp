import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Utils {
  String formatDateTime(DateTime dateTime) {
    return DateFormat('EEEE, MMM d, yyyy').format(dateTime);
  }

  
static Color primaryGreen = const Color(0xff009B22);
static Color lightGrey = const Color(0xffF4F4F4);
}

