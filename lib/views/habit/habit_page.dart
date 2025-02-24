import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:riseup/controllers/habit_controller.dart';
import 'package:riseup/models/habit_model.dart';
import 'package:riseup/services/habit_service.dart';
import 'package:riseup/utils/utils.dart';
import 'package:riseup/views/habit/edit_habit_page.dart';
import 'package:riseup/views/habit/habit_analytics_page.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  State<HabitPage> createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  //final HabitController _habitController = HabitController();

  final User? user = FirebaseAuth.instance.currentUser;
  final HabitService _habitService = HabitService();
  final HabitController _habitController = HabitController();

  //dialogue box
  Future<void> deleteDialogueBox(
      BuildContext context, String userId, String docId) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Delete?'),
            content: const Text(
              'Are you sure you want to delete?',
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge),
                child: const Text('Delete'),
                onPressed: () {
                  _habitController.deleteHabit(user!.uid, docId);

                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge),
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Utils.primaryGreen,
        title: const Text(
          'Habits',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'assets/fonts/Inter-Medium.ttf'),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<List<HabitModel>>(
          stream: _habitService.getHabits(user!.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            List<HabitModel> habits = snapshot.data!;
            return ListView.builder(
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  HabitModel habit = habits[index];

                  TimeOfDay? reminderTime;
                  DateTime? dateTime;
                  if (habit.reminderTime != null) {
                    if (habit.reminderTime is Timestamp) {
                      // Convert Timestamp to DateTime
                      DateTime timestampDate =
                          (habit.reminderTime as Timestamp).toDate();
                      reminderTime = TimeOfDay(
                          hour: timestampDate.hour,
                          minute: timestampDate.minute);
                    } else if (habit.reminderTime is TimeOfDay) {
                      // Directly use TimeOfDay
                      reminderTime = habit.reminderTime as TimeOfDay;
                    }
                  }
                  if (reminderTime != null) {
                    DateTime now = DateTime.now();
                    dateTime = DateTime(now.year, now.month, now.day,
                        reminderTime.hour, reminderTime.minute);
                  }
                  String reminderTimeForText = dateTime != null
                      ? DateFormat('h:mm a').format(dateTime)
                      : 'Not Set';

                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xffF4F4F4),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  habit.name.isNotEmpty
                                      ? habit.name[0].toUpperCase() +
                                          habit.name.substring(1)
                                      : "Unnamed Habit",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Color(0xff626262),
                                      ),
                                      onPressed: () {
                                        Get.to(EditHabitPage(docId: habit.id));
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.bar_chart_rounded,
                                          color: Color(0xff626262)),
                                      onPressed: () async {
                                        HabitModel hab = await _habitService
                                            .getHabitForAnalytics(
                                                user!.uid, habit.id);
                                        Get.to(HabitAnalyticsPage(
                                          habit: hab,
                                        ));
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Color(0xff626262),
                                      ),
                                      onPressed: () {
                                        deleteDialogueBox(
                                            context, user!.uid, habit.id);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Streak: ${habit.streak.toString()}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text('Score: ${habit.score.toString()}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                            Text('Reminder: $reminderTimeForText'),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  );
                });
          },
        ),
      ),
    );
  }
}
