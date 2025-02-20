import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:riseup/models/habit_model.dart';
import 'package:riseup/services/habit_service.dart';
import 'package:riseup/utils/utils.dart';

class HabitAnalyticsPage extends StatefulWidget {
  final HabitModel habit;
  const HabitAnalyticsPage({super.key, required this.habit});

  @override
  State<HabitAnalyticsPage> createState() => _HabitAnalyticsPageState();
}

class _HabitAnalyticsPageState extends State<HabitAnalyticsPage> {
  final HabitService _habitService = HabitService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Utils.primaryGreen,
        title: const Text(
          'Statistics',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'assets/fonts/Inter-Medium.ttf'),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Habit Score",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            CircularPercentIndicator(
              radius: 60.0,
              lineWidth: 10.0,
              percent: widget.habit.score / 100,
              center: Text("${widget.habit.score}"),
              progressColor: Colors.green,
            ),
            const SizedBox(
              height: 30,
            ),
            const Divider(),
            const SizedBox(
              height: 30,
            ),
            Text(
              "Streak: ${widget.habit.streak}", // ✅ Properly display streak
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            const Divider(),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
