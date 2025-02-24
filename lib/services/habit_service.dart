import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:riseup/models/habit_model.dart';
import 'package:riseup/services/notification_service.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user = FirebaseAuth.instance.currentUser;

  DateTime convertTimeOfDayToDateTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  //save habit to firestore
  Future<void> saveHabit(HabitModel habit) async {
    if (user != null) {
      await _firestore
          .collection('habits')
          .doc(user!.uid)
          .collection('habit')
          .add(habit.toJson());
    }
    if (habit.reminderTime != null && habit.days.isNotEmpty) {
      NotificationService.scheduleReminder(
          habit.id, habit.name, habit.reminderTime!, habit.days);
    } else {
      NotificationService.cancelNotification(habit.id, habit.days);
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

        var habit = HabitModel.fromJson(habitData, doc.id, isCompleted);
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
      String selectedDayName = DateFormat('EEEE').format(selectedDate);

      for (var doc in snapshot.docs) {
        var habitData = doc.data();

        // Parse 'createdAt' timestamp safely
        DateTime? createdAt = habitData['createdAt'] != null
            ? (habitData['createdAt'] as Timestamp).toDate()
            : null;

        // Convert 'createdAt' to Date-Only format for proper comparison
        if (createdAt != null) {
          createdAt = DateTime(createdAt.year, createdAt.month, createdAt.day);
        }
        DateTime selectedDateOnly =
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

        // Skip habits created after the selected date
        if (createdAt != null && createdAt.isAfter(selectedDateOnly)) {
          continue;
        }

        // Check if the habit is meant to be completed on this day
        List<dynamic> selectedDays = habitData['days'] ?? [];
        if (!selectedDays.map((e) => e.toString()).contains(selectedDayName)) {
          continue;
        }

        // Fetch habit completion status from logs subcollection
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
        await logRef.set({'completed': true}, SetOptions(merge: true));

        int streak = await calculateStreak(userId, habitId);
        int validCompletedDays = await countValidCompletedDays(userId, habitId);
        int score = _calculateScore(streak, validCompletedDays);

        await habitRef.update({
          'streak': streak,
          'score': score,
        });

        print(
            "✅ Habit completed - $habitId on $selectedDate. Streak: $streak, Valid Completed Days: $validCompletedDays, Score: $score");
      } catch (e) {
        print("🚨 Error in toggleHabitCompletion: $e");
      }
    } else {
      try {
        await logRef.delete();

        int updatedStreak = await calculateStreak(userId, habitId);
        int updatedValidCompletedDays =
            await countValidCompletedDays(userId, habitId);
        int updatedScore =
            _calculateScore(updatedStreak, updatedValidCompletedDays);

        await habitRef.update({
          'streak': updatedStreak,
          'score': updatedScore,
        });

        print(
            "❌ Habit unchecked - $habitId on $selectedDate. Updated Streak: $updatedStreak.");
      } catch (e) {
        print("🚨 Error deleting habit log: $e");
      }
    }
  }

  // Calculate streak based on previous day
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

    DateTime today = DateTime.now();
    DateTime currentDate = today;

    // Fetch all logs at once
    QuerySnapshot logsSnapshot = await _firestore
        .collection('habits')
        .doc(userId)
        .collection('habit')
        .doc(habitId)
        .collection('logs')
        .get();

    Map<String, bool> completedLogs = {};
    for (var doc in logsSnapshot.docs) {
      completedLogs[doc.id] =
          (doc.data() as Map<String, dynamic>)['completed'] ?? false;
    }

    int streak = 0;
    bool foundFirstCompletion = false;
    bool hasTodayCompleted =
        completedLogs[DateFormat('yyyy-MM-dd').format(today)] ?? false;

    while (true) {
      String dayName = DateFormat('EEEE').format(currentDate);
      if (!selectedDays.contains(dayName)) {
        currentDate = currentDate.subtract(const Duration(days: 1));
        continue;
      }

      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
      bool isCompleted = completedLogs[formattedDate] ?? false;

      if (isCompleted) {
        streak++;
        foundFirstCompletion = true;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        // Ensure today is counted if completed, even if yesterday is unchecked
        if (foundFirstCompletion && hasTodayCompleted) {
          return streak;
        }
        break;
      }
    }

    return foundFirstCompletion ? streak : (hasTodayCompleted ? 1 : 0);
  }

  // Calculate score based on streak
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

  // Get real-time habit completion status for a specific date
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

  //delete habit from firestore -> moved to controller
  Future<void> deleteHabit(String userId, String docId) async {
    DocumentSnapshot habitDoc = await FirebaseFirestore.instance
        .collection('habits')
        .doc(userId)
        .collection('habit')
        .doc(docId)
        .get();

    if (habitDoc.exists) {
      List<String> days = List<String>.from(habitDoc['days'] ?? []);

      await FirebaseFirestore.instance
          .collection('habits')
          .doc(userId)
          .collection('habit')
          .doc(docId)
          .delete();

      await NotificationService.cancelNotification(docId, days);
    }
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

  //update habit -> moved to controller
  Future<void> updateHabit(
      String userId, String habitId, HabitModel habit) async {
    await _firestore
        .collection('habits')
        .doc(userId)
        .collection('habit')
        .doc(habitId)
        .update(habit.toJson());

    // Cancel existing notifications before scheduling new ones
    await NotificationService.cancelNotification(habit.id, habit.days);

    if (habit.reminderTime != null && habit.days.isNotEmpty) {
      await NotificationService.scheduleReminder(
          habit.id, habit.name, habit.reminderTime!, habit.days);
    }
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
