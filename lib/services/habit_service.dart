import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:riseup/models/habit_model.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user = FirebaseAuth.instance.currentUser;

  //save habit to firestore
  Future<void> saveHabit(HabitModel habit) async {
    if (user != null) {
      await _firestore
          .collection('habits')
          .doc(user!.uid)
          .collection('habit')
          .add(habit.toJson());
    }
  }

  //get habits for a user
 Stream<List<HabitModel>> getHabits(String userId) {
  DateTime today = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(today);

  return _firestore
      .collection('habits')
      .doc(userId)
      .collection('habit')
      .snapshots()
      .asyncMap((snapshot) async {
        List<HabitModel> habits = [];

        for (var doc in snapshot.docs) {
          var habitData = doc.data();

          // Fetch the completion status from the 'logs' subcollection
          var logSnapshot = await doc.reference.collection('logs').doc(formattedDate).get();
          bool isCompleted = logSnapshot.exists ? (logSnapshot['completed'] ?? false) : false;

          var habit = HabitModel.fromJson(habitData, doc.id, isCompleted); // ✅ Pass completed
          habits.add(habit);
        }

        return habits;
      });
}


  //load selected day habits
Stream<List<HabitModel>> getSelectedDayHabits(DateTime selectedDate, String userId) {
  return _firestore
      .collection('habits')
      .doc(userId)
      .collection('habit')
      .snapshots()
      .asyncMap((snapshot) async {
        List<HabitModel> habits = [];

        for (var doc in snapshot.docs) {
          var habitData = doc.data();
          var createdAt = habitData['createdAt'] != null
              ? (habitData['createdAt'] as Timestamp).toDate()
              : null;

          if (createdAt == null || createdAt.isAfter(selectedDate)) {
            continue; // Skip if habit was created after the selected date
          }

          // Fetch the completion status from 'logs' subcollection
          String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
          var logSnapshot = await doc.reference.collection('logs').doc(formattedDate).get();
          bool isCompleted = logSnapshot.exists ? (logSnapshot['completed'] ?? false) : false;

          var habit = HabitModel.fromJson(habitData, doc.id, isCompleted); // ✅ Pass completed
          habits.add(habit);
        }

        return habits;
      });
}


  //function to toggle habit completion
Future<void> toggleHabitCompletion(String userId, String habitId, String selectedDate, bool isCompleted) async {
  DocumentReference logRef = _firestore
      .collection('habits')
      .doc(userId)
      .collection('habit')
      .doc(habitId)
      .collection('logs')
      .doc(selectedDate);

  if (isCompleted) {
    print("Before update - Setting completion to: $isCompleted for $habitId on $selectedDate");
    await logRef.set({'completed': true}, SetOptions(merge: true));
    print("After update - Completion updated to: $isCompleted");
  } else {
    print("Before delete - Removing completion for $habitId on $selectedDate");
    await logRef.delete();
    print("After delete - Completion removed.");
  }
}



  // 🔹 Get real-time habit completion status for a specific date
Stream<DocumentSnapshot> getHabitCompletionStream(String userId, String habitId, String selectedDate) {
  return _firestore
      .collection('habits')
      .doc(userId)
      .collection('habit')
      .doc(habitId)
      .collection('logs')
      .doc(selectedDate)
      .snapshots()
      .map((snapshot) {
        bool isCompleted = snapshot.exists && (snapshot.data()?['completed'] ?? false);
        print("Firestore update detected - $habitId on $selectedDate: $isCompleted");
        return snapshot;
      });
}

}
