import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:riseup/controllers/habit_controller.dart';
import 'package:riseup/models/habit_model.dart';
import 'package:riseup/utils/utils.dart';

class HabitPage extends StatelessWidget {
  HabitPage({super.key});

  final HabitController _habitController = HabitController();
  User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<HabitModel>> getAllHabits() {
    if (user != null) {
      return _firestore
          .collection('habits')
          .doc(user!.uid)
          .collection('habit')
          .snapshots()
          .map((snapshot) {
        print('Stream triggred');
        print("Fetched data: ${snapshot.docs.length} habits found");
        return snapshot.docs.map((doc) {
          var habit = HabitModel.fromJson(doc.data(), doc.id);
          print("Habit data: ${habit.name}, ${habit.days}, ${habit.reminderTime}");
          return habit;
        }).toList();
      });
    } else {
      return Stream.value([]);
    }
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
          stream: getAllHabits(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            List<HabitModel> habits = snapshot.data!;
            return Expanded(
              child: ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    HabitModel habit = habits[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(habit.name),
                        Text(habit.days.join(', ')),
                        Text(
                          DateFormat('hh:mm a').format(DateTime(
                              2021,
                              1,
                              1,
                              habit.reminderTime.hour,
                              habit.reminderTime.minute)),
                        ),
                      ],
                    );
                  }),
            );
          },
        ),
      ),
    );
  }
}
