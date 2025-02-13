import 'package:cloud_firestore/cloud_firestore.dart';

class JournalModel {
  String title;
  String description;
  DateTime date;

  JournalModel(
      {required this.title, required this.description, required this.date});

  //convert to json file for firestore
  Map<String, dynamic> toJson() {
    return {
      'date': Timestamp.fromDate(date),
      'title': title,
      'description': description
    };
  }

  //convert json to journal model object
  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
        title: (json['title'] as String),
        description: (json['description'] as String),
        date: (json['date'] as Timestamp).toDate());
  }
}
