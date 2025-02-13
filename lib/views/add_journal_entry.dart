import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riseup/controllers/journal_controller.dart';
import 'package:riseup/models/journal_model.dart';

class AddJournalPage extends StatelessWidget {
  AddJournalPage({super.key});

  final JournalController _journalController = Get.put(JournalController());

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _saveJournalEntry() {
    final entry = JournalModel(
        date: DateTime.now(),
        title: _titleController.text,
        description: _descriptionController.text);
    _journalController.saveJournalEntry(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new journal'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                _saveJournalEntry();
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
