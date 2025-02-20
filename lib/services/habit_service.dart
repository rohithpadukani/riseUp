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
        var logSnapshot =
            await doc.reference.collection('logs').doc(formattedDate).get();
        bool isCompleted =
            logSnapshot.exists ? (logSnapshot['completed'] ?? false) : false;

        var habit = HabitModel.fromJson(
            habitData, doc.id, isCompleted); // ✅ Pass completed
        habits.add(habit);
      }

      return habits;
    });
  }

  //load selected day habits
  Stream<List<HabitModel>> getSelectedDayHabits(
      DateTime selectedDate, String userId) {
    return _firestore
        .collection('habits')
        .doc(userId)
        .collection('habit')
        .snapshots()
        .asyncMap((snapshot) async {
      List<HabitModel> habits = [];
      String selectedDayName =
          DateFormat('EEEE').format(selectedDate); // e.g., "Monday"

      for (var doc in snapshot.docs) {
        var habitData = doc.data();

        // ✅ Parse 'createdAt' timestamp safely
        DateTime? createdAt = habitData['createdAt'] != null
            ? (habitData['createdAt'] as Timestamp).toDate()
            : null;

        // ✅ Convert 'createdAt' to Date-Only format for proper comparison
        if (createdAt != null) {
          createdAt = DateTime(createdAt.year, createdAt.month, createdAt.day);
        }
        DateTime selectedDateOnly =
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

        // ✅ Skip habits created after the selected date
        if (createdAt != null && createdAt.isAfter(selectedDateOnly)) {
          continue;
        }

        // ✅ Check if the habit is meant to be completed on this day
        List<dynamic> selectedDays = habitData['days'] ?? [];
        if (!selectedDays.map((e) => e.toString()).contains(selectedDayName)) {
          continue;
        }

        // ✅ Fetch habit completion status from logs subcollection
        String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
        var logSnapshot =
            await doc.reference.collection('logs').doc(formattedDate).get();
        bool isCompleted =
            logSnapshot.exists ? (logSnapshot['completed'] ?? false) : false;

        var habit = HabitModel.fromJson(habitData, doc.id, isCompleted);
        habits.add(habit);
      }

      return habits;
    });
  }

  //function to toggle habit completion
  Future<void> toggleHabitCompletion(String userId, String habitId,
      String selectedDate, bool isCompleted) async {
    DocumentReference habitRef = _firestore
        .collection('habits')
        .doc(userId)
        .collection('habit')
        .doc(habitId);

    DocumentReference logRef = habitRef.collection('logs').doc(selectedDate);

    if (isCompleted) {
      try {
        int streak = await calculateStreak(userId, habitId);
        int validCompletedDays = await countValidCompletedDays(userId, habitId);
        int score = _calculateScore(streak, validCompletedDays);

        await habitRef.update({
          'streak': streak,
          'score': score,
        });

        await logRef.set({'completed': true}, SetOptions(merge: true));

        print(
            "✅ Habit completed - $habitId on $selectedDate. Streak: $streak, Valid Completed Days: $validCompletedDays, Score: $score");
      } catch (e) {
        print("🚨 Error in toggleHabitCompletion: $e");
      }
    } else {
      try {
        await logRef.delete();

        // 🔥 Calculate streak again
        int updatedStreak = await calculateStreak(userId, habitId);
        int updatedValidCompletedDays =
            await countValidCompletedDays(userId, habitId);
        int updatedScore =
            _calculateScore(updatedStreak, updatedValidCompletedDays);

        // ✅ Explicitly set streak to 0 if there are no completed logs
        if (updatedStreak == 1) {
          DocumentSnapshot lastLog = await logRef.get();
          if (!lastLog.exists) {
            updatedStreak = 0;
          }
        }

        await habitRef.update({
          'streak': updatedStreak,
          'score': updatedScore,
        });

        print(
            "❌ Habit unchecked - $habitId on $selectedDate. Streak reset to $updatedStreak, Valid Completed Days: $updatedValidCompletedDays.");
      } catch (e) {
        print("🚨 Error deleting habit log: $e");
      }
    }
  }

  // 🔹 Calculate streak based on previous day
  Future<int> calculateStreak(String userId, String habitId) async {
    DocumentSnapshot habitDoc = await _firestore
        .collection('habits')
        .doc(userId)
        .collection('habit')
        .doc(habitId)
        .get();

    if (!habitDoc.exists) return 0;

    Map<String, dynamic>? habitData = habitDoc.data() as Map<String, dynamic>?;
    List<dynamic> selectedDays = habitData?['days'] ?? [];

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime currentDate = today;

    bool foundFirstCompletion = false; // ✅ Track first completion

    while (true) {
      String dayName = DateFormat('EEEE').format(currentDate);

      // 🔥 Ignore days that are not part of the habit schedule
      if (!selectedDays.contains(dayName)) {
        currentDate = currentDate.subtract(Duration(days: 1));
        continue;
      }

      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
      DocumentSnapshot logSnapshot = await _firestore
          .collection('habits')
          .doc(userId)
          .collection('habit')
          .doc(habitId)
          .collection('logs')
          .doc(formattedDate)
          .get();

      if (logSnapshot.exists && logSnapshot['completed'] == true) {
        streak++;
        foundFirstCompletion = true; // ✅ Found at least one completion
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break; // Streak ends
      }
    }

    return foundFirstCompletion ? streak : 1; // ✅ Ensure streak is at least 1
  }

  // 🔹 Calculate score based on streak
  int _calculateScore(int streak, int validCompletedDays) {
    double streakWeight = 0.6;
    double completedDaysWeight = 0.4;

    int maxStreak = 10;
    int maxCompletedDays = 30;

    double normalizedStreak = (streak.clamp(0, maxStreak) / maxStreak) * 100;
    double normalizedCompletedDays =
        (validCompletedDays.clamp(0, maxCompletedDays) / maxCompletedDays) *
            100;

    int score = ((normalizedStreak * streakWeight) +
            (normalizedCompletedDays * completedDaysWeight))
        .round();

    return score.clamp(0, 100);
  }

//count valid completed days
  Future<int> countValidCompletedDays(String userId, String habitId) async {
    DocumentSnapshot habitDoc = await _firestore
        .collection('habits')
        .doc(userId)
        .collection('habit')
        .doc(habitId)
        .get();

    if (!habitDoc.exists) return 0;

    Map<String, dynamic>? habitData = habitDoc.data() as Map<String, dynamic>?;
    List<dynamic> selectedDays = habitData?['days'] ?? [];

    QuerySnapshot logSnapshot = await _firestore
        .collection('habits')
        .doc(userId)
        .collection('habit')
        .doc(habitId)
        .collection('logs')
        .where('completed', isEqualTo: true)
        .get();

    int validCompletedDays = 0;

    for (var log in logSnapshot.docs) {
      DateTime logDate = DateTime.parse(log.id);
      String logDayName = DateFormat('EEEE').format(logDate);

      if (selectedDays.contains(logDayName)) {
        validCompletedDays++;
      }
    }

    return validCompletedDays;
  }

  // 🔹 Get real-time habit completion status for a specific date
  Stream<DocumentSnapshot> getHabitCompletionStream(
      String userId, String habitId, String selectedDate) {
    return _firestore
        .collection('habits')
        .doc(userId)
        .collection('habit')
        .doc(habitId)
        .collection('logs')
        .doc(selectedDate)
        .snapshots()
        .asyncMap((snapshot) {
      bool isCompleted =
          snapshot.exists && (snapshot.data()?['completed'] ?? false);
      print(
          "Firestore update detected - $habitId on $selectedDate: $isCompleted");
      return snapshot;
    });
  }

  // 🔹 Helper function to format date as yyyy-MM-dd
  String _getFormattedDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  //delete habit from firestore

  //delete journal from firestore
  Future<void> deleteJournalEntry(String userId, String docId) async {
    await FirebaseFirestore.instance
        .collection('habits')
        .doc(userId)
        .collection('habit')
        .doc(docId)
        .delete();
  }

  //fetch single habit data from firestore as object
  Future<HabitModel?> getHabit(String userId, String habitId) async {
    DocumentSnapshot doc = await _firestore
        .collection('habits')
        .doc(userId)
        .collection('habit')
        .doc(habitId)
        .get();

    if (!doc.exists) return null;
    return HabitModel.fromJsonForEdit(
        doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> updateHabit(
      String userId, String habitId, HabitModel habit) async {
    await _firestore
        .collection('habits')
        .doc(userId)
        .collection('habit')
        .doc(habitId)
        .update(habit.toJson());
  }

  //fetch habits for analytics
  
  Future<HabitModel> getHabitForAnalytics(String userId, String habitId) async {
    DocumentSnapshot doc = await _firestore
        .collection('habits')
        .doc(userId)
        .collection('habit')
        .doc(habitId)
        .get();
    return HabitModel.fromJsonForEdit(
        doc.data() as Map<String, dynamic>, doc.id);
  }
}
