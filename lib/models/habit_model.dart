import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HabitModel {
  final String id;
  final String name;
  final List<String> days;
  final TimeOfDay reminderTime;
  int streak;
  int score;

  HabitModel(
      {required this.id,
      required this.name,
      required this.days,
      required this.reminderTime,
      required this.streak,
      required this.score});

  //convert to json
  Map<String, dynamic> toJson() {

    final now = DateTime.now();

    final reminderDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute
    );
    return {
      'name': name,
      'days': days,
      'reminderTime': Timestamp.fromDate(reminderDateTime),
      'streak': streak,
      'score': score,
    };
  }

  //convert timestamp to timeofday
  static timestampToTimeofday(Timestamp timestamp){
    DateTime dateTime = timestamp.toDate();
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  //convert back to model
  factory HabitModel.fromJson(Map<String, dynamic> json, String id) {
    return HabitModel(
        id: id,
        name: json['name'],
        days: List<String>.from(json['days']),
        reminderTime: HabitModel.timestampToTimeofday(json['reminderTime']),
        streak: json['streak'],
        score: json['score']);
  }
}
