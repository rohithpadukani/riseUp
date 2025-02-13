import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:riseup/controllers/journal_controller.dart';
import 'package:riseup/models/journal_model.dart';
import 'package:riseup/utils/utils.dart';

class AddJournalPage extends StatelessWidget {
  AddJournalPage({super.key});
  final Utils utils = Utils();

  final JournalController _journalController = Get.put(JournalController());

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _saveJournalEntry() {
    final entry = JournalModel(
        docId: '',
        date: DateTime.now(),
        title: _titleController.text,
        description: _descriptionController.text);

    _journalController.saveJournalEntry(entry);
  }

  DateTime currentTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Add New Entry',
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
              fontFamily: 'assets/fonts/Inter-Regular.ttf'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.close,
              size: 26,
              color: Colors.black,
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            //date and time container
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM d').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff434343),
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff434343),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      //pick calendar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: const Color(0xffD9D9D9),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(
                          Icons.calendar_month,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      //pick time
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: const Color(0xffD9D9D9),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.access_time_filled),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        DateFormat('h:mm a').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff009B22),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
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
