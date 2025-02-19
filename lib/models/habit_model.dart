import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HabitModel {
  final String id;
  final String name;
  final List<String> days;
  final TimeOfDay reminderTime;
  int streak;
  int score;
  DateTime? createdAt;
  bool completed;

  HabitModel({
    required this.id,
    required this.name,
    required this.days,
    required this.reminderTime,
    required this.streak,
    required this.score,
    this.createdAt,
    this.completed = false,//default false
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    final now = DateTime.now();
    final reminderDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    return {
      'name': name,
      'days': days,
      'reminderTime': Timestamp.fromDate(reminderDateTime),
      'streak': streak,
      'score': score,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Convert Firestore Timestamp to TimeOfDay
  static TimeOfDay timestampToTimeOfDay(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  // Convert JSON to HabitModel
  factory HabitModel.fromJson(Map<String, dynamic> json, String id, bool completed){
    return HabitModel(
      id: id,
      name: json['name'] ?? 'Unknown Habit',
      days: List<String>.from(json['days'] ?? []),
      reminderTime:
          timestampToTimeOfDay(json['reminderTime'] ?? Timestamp.now()),
      streak: json['streak'] ?? 0,
      score: json['score'] ?? 0,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
          completed: completed,
    );
  }
}
