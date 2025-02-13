import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:riseup/controllers/journal_controller.dart';
import 'package:riseup/models/journal_model.dart';
import 'package:riseup/routes/app_routes.dart';
import 'package:riseup/utils/utils.dart';
import 'package:riseup/views/edit_journal_entry.dart';

class JournalPage extends StatelessWidget {
  JournalPage({super.key});
  final Utils utils = Utils();

  final JournalController _journalController = Get.put(JournalController());

  Stream<List<JournalModel>> getAllUsers() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return FirebaseFirestore.instance
          .collection('journals')
          .doc(user.uid)
          .collection('entries')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return JournalModel.fromJson(doc.data(), doc.id);
        }).toList();
      });
    } else {
      return Stream.value([]);
    }
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('EEEE, MMM d, yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            StreamBuilder<List<JournalModel>>(
                stream: getAllUsers(),
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
                          return Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.title),
                                    Text(entry.description),
                                    Text(formatDateTime(entry.date)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Get.to(EditJournalEntry(
                                                docId: entry.docId,
                                                currentTitle: entry.title,
                                                currentDescription:
                                                    entry.description));
                                          },
                                          icon: Icon(Icons.edit),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Icon(Icons.delete),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                            ],
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
