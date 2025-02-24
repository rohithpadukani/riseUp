import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:riseup/models/habit_model.dart';
import 'package:riseup/services/habit_service.dart';

class HabitController extends GetxController {
  User? user = FirebaseAuth.instance.currentUser;
  final HabitService _habitService = HabitService();

  //save habit to firestore
  Future<void> saveHabit(HabitModel habit) async {
    try {
      _habitService.saveHabit(habit);
      Get.snackbar('Saved', 'New habit added');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save habit $e');
    }
  }

  //update habit
  Future<void> updateHabit(
      String userId, String habitId, HabitModel habit) async {
    try {
      _habitService.updateHabit(userId, habitId, habit);
      Get.snackbar('Updated', 'Habit updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Error updating habit: $e');
    }
  }

  //delete habit from firestore
  Future<void> deleteHabit(String userId, String docId) async {
    try {
      await _habitService.deleteHabit(userId, docId);
      Get.snackbar('Deleted', 'Habit deleted successfully');
    } catch (e) {
      Get.snackbar('Failed', 'Failed to delete! $e');
    }
  }
  //end of main state
}
