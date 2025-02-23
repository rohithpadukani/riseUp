import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(settings);
  }

  // 🔹 Convert weekday string to DateTime
  static DateTime _getNextOccurrence(String day, TimeOfDay time) {
    DateTime now = DateTime.now();
    List<String> weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    int todayIndex = now.weekday - 1; // Convert 1-based index to 0-based
    int targetIndex = weekDays.indexOf(day);

    int daysUntilNext = (targetIndex - todayIndex) % 7;
    if (daysUntilNext == 0 &&
        (now.hour > time.hour ||
            (now.hour == time.hour && now.minute >= time.minute))) {
      daysUntilNext = 7; // Move to next week if the time has passed
    }

    DateTime nextDate = now.add(Duration(days: daysUntilNext));
    print(
        "🔔 Scheduled for: ${nextDate.toLocal()} at ${time.hour}:${time.minute}");

    return DateTime(
        nextDate.year, nextDate.month, nextDate.day, time.hour, time.minute);
  }

  // 🔹 Schedule Habit Notification on Specific Days
  static Future<void> scheduleReminder(String habitId, String title,
      TimeOfDay reminderTime, List<String> days) async {
    for (String day in days) {
      DateTime scheduleTime = _getNextOccurrence(day, reminderTime);

      // ✅ Ensure it's correctly scheduled on that specific day
      final tz.TZDateTime scheduledDate =
          tz.TZDateTime.from(scheduleTime, tz.local);

      print("✅ Scheduling notification for $day at $scheduledDate");

      await _notificationsPlugin.zonedSchedule(
        habitId.hashCode ^
            day.hashCode, // Unique ID for each day's notification
        title,
        "Time to work on your habit!",
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_channel',
            'Habit Reminders',
            channelDescription: 'Reminder for daily habits',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents
            .dayOfWeekAndTime, // ✅ Ensures correct day scheduling
      );
    }
  }

  // 🔹 Cancel All Notifications for a Habit
  static Future<void> cancelNotification(
      String habitId, List<String> days) async {
    for (String day in days) {
      await _notificationsPlugin.cancel(habitId.hashCode ^ day.hashCode);
    }
  }
}
