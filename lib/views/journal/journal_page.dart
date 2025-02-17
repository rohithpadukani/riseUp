import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:riseup/controllers/journal_controller.dart';
import 'package:riseup/models/journal_model.dart';
import 'package:riseup/views/journal/edit_journal_entry.dart';

class JournalPage extends StatelessWidget {
  JournalPage({super.key});

  final JournalController _journalController = Get.put(JournalController());
  final User? user = FirebaseAuth.instance.currentUser;

  //dialogue box
  Future<void> deleteDialogueBox(
      BuildContext context, String userId, String docId) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Delete?'),
            content: const Text(
              'Are you sure you want to delete?',
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge),
                child: const Text('Delete'),
                onPressed: () {
                  _journalController.deleteJournalEntry(userId, docId);
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge),
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Stream<List<JournalModel>> getAllUsers() {
    //User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('journals')
          .doc(user!.uid)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Journal',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'assets/fonts/Inter-Medium.ttf'),
        ),
        backgroundColor: const Color(0xff009B22),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Container(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            StreamBuilder<List<JournalModel>>(
                stream: getAllUsers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  List<JournalModel> entries = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          JournalModel entry = entries[index];
                          //main column
                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //date, edit, delete
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    //date
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //15 feb, time
                                          Row(
                                            children: [
                                              Text(
                                                DateFormat('d MMM')
                                                    .format(entry.date),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 18,
                                                    fontFamily:
                                                        'assets/fonts/Inter-Bold.ttf'),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                DateFormat.jm().format(entry.date),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xff009B22),
                                                    fontSize: 15,
                                                    fontFamily:
                                                        'assets/fonts/Inter-Bold.ttf'),
                                              ),
                                            ],
                                          ),

                                          //wednesday, 2025
                                          Text(
                                            DateFormat('EEEE, yyyy')
                                                .format(entry.date),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                                fontFamily:
                                                    'assets/fonts/Inter-Medium.ttf'),
                                          ),
                                        ]),
                                    //edit, delete buttons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Get.to(EditJournalEntry(
                                                docId: entry.docId));
                                          },
                                          icon: const Icon(Icons.edit),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            deleteDialogueBox(context,
                                                user!.uid, entry.docId);
                                          },
                                          child: const Icon(Icons.delete),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  entry.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17,
                                      fontFamily:
                                          'assets/fonts/Inter-Mediumn.ttf'),
                                ),
                                Text(
                                  entry.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily:
                                          'assets/fonts/Inter-Regular.ttf'),
                                ),
                                const Divider(),
                              ]);
                        }),
                  );
                }),
          ],
        ),
      ),
    );
  }
}