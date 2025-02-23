import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:riseup/models/habit_model.dart';
import 'package:riseup/services/habit_service.dart';

class HabitController {
  final HabitService _habitService = HabitService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  //save habit
  Future<void> saveHabit(HabitModel habit) async {
    try {
      await _habitService.saveHabit(habit);
      Get.back();
      Get.snackbar('Success', 'Habit saved');
    } catch (e) {
      print('Erros is $e');
      Get.snackbar('Error', '$e');
    }
  }

  //end of main state
}
