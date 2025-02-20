import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riseup/models/habit_model.dart';
import 'package:riseup/services/habit_service.dart';

class EditHabitPage extends StatefulWidget {
  final String docId;

  const EditHabitPage({super.key, required this.docId});

  @override
  State<EditHabitPage> createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> {
  final TextEditingController _habitNameController = TextEditingController();
  final HabitService _habitService = HabitService();

  List<String> _selectedDays = [];
  TimeOfDay? _selectedTime;
  bool isSwitched = false;

  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadHabit();
  }

  // Load habit details from Firestore
Future<void> _loadHabit() async {
  if (user == null) return;

  HabitModel? habit = await _habitService.getHabit(user!.uid, widget.docId);

  if (habit != null) {
    setState(() {
      _habitNameController.text = habit.name;
      _selectedDays = List.from(habit.days); // Ensure previous days are fetched

      // Convert Firestore Timestamp to TimeOfDay
      if (habit.reminderTime != null) {
        _selectedTime = habit.reminderTime;
        isSwitched = true; // Enable switch if reminder exists
      }
    });
  }
}



  void _toggleDaySelection(String day) {
    setState(() {
      _selectedDays.contains(day)
          ? _selectedDays.remove(day)
          : _selectedDays.add(day);
    });
  }

  void _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        isSwitched = true;
      });
    }
  }

  // Update habit in Firestore
Future<void> _updateHabit() async {
  if (_habitNameController.text.isEmpty) {
    Get.snackbar("Error", "Habit name cannot be empty");
    return;
  }

  if (user == null) {
    Get.snackbar("Error", "User not logged in");
    return;
  }

  // Fetch the existing habit data to retain streak & score
  HabitModel? existingHabit = await _habitService.getHabit(user!.uid, widget.docId);

  if (existingHabit == null) {
    Get.snackbar("Error", "Habit not found");
    return;
  }

  final habit = HabitModel(
    id: widget.docId,
    name: _habitNameController.text,
    days: _selectedDays, // Replace with new days instead of appending
    reminderTime: _selectedTime ?? existingHabit.reminderTime, // Keep existing if not updated
    streak: existingHabit.streak, // Retain previous streak value
    score: existingHabit.score, // Retain previous score value
  );

  await _habitService.updateHabit(user!.uid, widget.docId, habit);
  Get.back();
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Habit")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit Name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xffF4F4F4),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _habitNameController,
                decoration: const InputDecoration(
                  hintText: "Habit Name",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Repeat Days
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xffF4F4F4),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Repeat"),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

                        .map((day) {
                      bool isSelected = _selectedDays.contains(day);
                      return GestureDetector(
                        onTap: () => _toggleDaySelection(day),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xffAEF397)
                                : const Color(0xffD5D5D5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            day.substring(0, 1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Reminder Time
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xffF4F4F4),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Reminder: ${_selectedTime != null ? _selectedTime!.format(context) : "Not Set"}",
                  ),
                  Switch(
                    value: isSwitched,
                    activeColor: Colors.green,
                    onChanged: (bool value) {
                      if (value) {
                        _pickTime();
                      } else {
                        setState(() {
                          _selectedTime = null;
                          isSwitched = false;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Save Button
            GestureDetector(
              onTap: _updateHabit,
              child: Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xff009B22),
                ),
                child: const Center(
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
