import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:riseup/controllers/journal_controller.dart';
import 'package:riseup/services/journal_service.dart';

class EditJournalEntry extends StatefulWidget {
  final String docId;
  final String currentTitle;
  final String currentDescription;

  EditJournalEntry(
      {required this.docId,
      required this.currentTitle,
      required this.currentDescription,
      super.key});

  @override
  State<EditJournalEntry> createState() => _EditJournalEntryState();
}

class _EditJournalEntryState extends State<EditJournalEntry> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final JournalController _journalController = JournalController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.currentTitle;
    _descriptionController.text = widget.currentDescription;
  }

  Future<void> updateJournalEntry() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _journalController.updateJournalEntry(user.uid, widget.docId,
          _titleController.text, _descriptionController.text);
    }
  }

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Journal Entry'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                updateJournalEntry();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
