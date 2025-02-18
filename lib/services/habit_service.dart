import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
}
