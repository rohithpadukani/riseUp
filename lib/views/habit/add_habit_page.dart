import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riseup/controllers/habit_controller.dart';
import 'package:riseup/models/habit_model.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final TextEditingController _habitNameController = TextEditingController();
  final HabitController _habitController = HabitController();
  List<String> _selectedDays = [];
  TimeOfDay? _selectedTime;
  int streak = 0;
  int score = 0;

  final List<String> _weekDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

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
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  bool isSwitched = false;

  //save habit
  Future<void> _saveHabit() async {
    final habit = HabitModel(
      id: '',
      name: _habitNameController.text,
      days: _selectedDays,
      reminderTime : _selectedTime!,
      streak: streak,
      score: score,
    );
    await _habitController.saveHabit(habit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Habit"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //habit name container
              Container(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xffF4F4F4),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _habitNameController,
                  style:
                      const TextStyle(color: Color(0xff434343), fontSize: 17),
                  decoration: const InputDecoration(
                    hintText: "Habit Name",
                    hintStyle:
                        TextStyle(color: Color(0xff434343), fontSize: 17),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              //repeat main container
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xffF4F4F4),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Repeat',
                      style: TextStyle(color: Color(0xff434343), fontSize: 17),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Wrap(
                      spacing: 10.0,
                      children: _weekDays.map((day) {
                        bool isSelected = _selectedDays.contains(day);
                        return GestureDetector(
                          onTap: () {
                            _toggleDaySelection(day);
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 12, top: 5, right: 12, bottom: 5),
                            decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xffAEF397)
                                    : const Color(0xffD5D5D5),
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              day.substring(0, 1),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              //reminder container
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xffF4F4F4),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Reminder: ',
                              style: TextStyle(
                                  color: Color(0xff434343), fontSize: 17),
                            ),
                            Text(
                              (_selectedTime != null
                                  ? _selectedTime!.format(context)
                                  : "Not Set"),
                              style: const TextStyle(
                                  color: Color(0xff434343),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Switch(
                          value: isSwitched,
                          activeColor: Colors.green,
                          onChanged: (bool value) {
                            if (!isSwitched) {
                              _pickTime();
                              setState(() {
                                isSwitched = value;
                              });
                            } else {
                              setState(() {
                                _selectedTime = null;
                                isSwitched = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              GestureDetector(
                onTap: () {
                  _saveHabit();
                  Get.back();
                },
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
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
