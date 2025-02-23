import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:riseup/models/habit_model.dart';
import 'package:riseup/utils/utils.dart';
import 'package:table_calendar/table_calendar.dart';

class HabitAnalyticsPage extends StatefulWidget {
  final HabitModel habit;
  const HabitAnalyticsPage({super.key, required this.habit});

  @override
  State<HabitAnalyticsPage> createState() => _HabitAnalyticsPageState();
}

class _HabitAnalyticsPageState extends State<HabitAnalyticsPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  List<DateTime> _completedDays = [];
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    fetchCompletedDays();
  }

  /// Fetches completed habit days from Firestore logs collection
  Future<void> fetchCompletedDays() async {
    String userId = user!.uid; // Replace with actual user ID
    String habitId = widget.habit.id; // Habit ID from widget

    CollectionReference logsRef = FirebaseFirestore.instance
        .collection('habits')
        .doc(userId)
        .collection('habit')
        .doc(habitId)
        .collection('logs');

    try {
      QuerySnapshot snapshot = await logsRef.get();

      List<DateTime> completedDates = snapshot.docs
          .map((doc) {
            try {
              return DateFormat('yyyy-MM-dd')
                  .parse(doc.id); // Convert doc ID to DateTime
            } catch (e) {
              print("Error parsing date: ${doc.id} - $e");
              return null;
            }
          })
          .where((date) => date != null)
          .cast<DateTime>()
          .toList();

      setState(() {
        _completedDays = completedDates;
      });
    } catch (e) {
      print("Error fetching completed days: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Utils.primaryGreen,
        title: Text(
          widget.habit.name,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'assets/fonts/Inter-Medium.ttf'),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Habit Score",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 10.0,
                percent: widget.habit.score / 100,
                center: Text("${widget.habit.score}"),
                progressColor: Colors.green,
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 30),
              Text(
                "Streak: ${widget.habit.streak}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 30),
              const Text(
                "Habit Completion Calendar",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                selectedDayPredicate: (day) {
                  return _completedDays.any((completedDay) =>
                      completedDay.year == day.year &&
                      completedDay.month == day.month &&
                      completedDay.day == day.day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month', // Only show full month
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false, // Hide the format button
                  titleCentered: true, // Center the month-year title
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
