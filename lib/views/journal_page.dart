import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:riseup/controllers/journal_controller.dart';
import 'package:riseup/models/journal_model.dart';

class JournalPage extends StatelessWidget {
  JournalPage({super.key});

  final JournalController _journalController = Get.put(JournalController());

  Stream<List<JournalModel>> streamEntries() {
    return FirebaseFirestore.instance
        .collection('journal')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return JournalModel.fromJson(doc.data());
      }).toList();
    });
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('EEEE, MMM d, yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habits page'),
      ),
      body: Container(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            StreamBuilder<List<JournalModel>>(
                stream: streamEntries(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  List<JournalModel> entries = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          JournalModel entry = entries[index];
                          return ListTile(
                            title: Text(entry.title),
                            subtitle: Text(
                                '${entry.description}\n Time: ${formatDateTime(entry.date)}'),
                          );
                        }),
                  );
                })
          ],
        ),
      ),
    );
  }
}
