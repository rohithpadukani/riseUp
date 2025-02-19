import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:riseup/controllers/journal_controller.dart';
import 'package:riseup/models/journal_model.dart';

class EditJournalEntry extends StatefulWidget {
  final String docId;
  const EditJournalEntry({required this.docId, super.key});

  @override
  State<EditJournalEntry> createState() => _EditJournalEntryState();
}

class _EditJournalEntryState extends State<EditJournalEntry> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final JournalController _journalController = JournalController();

  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadEntry();
  }

  //method to update single journal entry
  Future<void> updateJournalEntry() async {
    if (user != null) {
      DateTime finalDatetime = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, selectedDate.hour, selectedDate.minute);
      _journalController.updateJournalEntry(
          user!.uid,
          widget.docId,
          _titleController.text,
          _descriptionController.text,
          Timestamp.fromDate(finalDatetime));
    }
  }

  //DateTime selectedTime = DateTime.now();
  DateTime selectedDate = DateTime.now();

  JournalModel? journalEntry;

  //method to load the entry
  Future<void> loadEntry() async {
    JournalModel? entry =
        await _journalController.getEntry(user!.uid, widget.docId);
    if (entry != null) {
      setState(() {
        journalEntry = entry;
        _titleController.text = journalEntry!.title;
        _descriptionController.text = journalEntry!.description;
      });
    }
  }

  //method to pick time
  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );
    if (pickedTime != null) {
      setState(() {
        DateTime oldDay = journalEntry!.date;
        selectedDate = DateTime(oldDay.year, oldDay.month, oldDay.day,
            pickedTime.hour, pickedTime.minute);
        journalEntry!.date = selectedDate;
      });
    }
  }

  //method to pick date
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: journalEntry!.date,
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
    );
    if (pickedDate != null) {
      setState(() {
        DateTime oldDay = journalEntry!.date;
        selectedDate = DateTime(pickedDate.year, pickedDate.month,
            pickedDate.day, oldDay.hour, oldDay.minute);
        journalEntry!.date = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Journal Entry',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () {
              updateJournalEntry();
            },
            child: const Text(
              'Save',
              style: TextStyle(
                  color: Color(0xff009B22),
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ],
      ),
      body: journalEntry == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  //date and time container
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMMM d').format(journalEntry!.date),
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff434343),
                            ),
                          ),
                          Text(
                            DateFormat('EEEE, yyyy').format(journalEntry!.date),
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
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color: const Color(0xffD9D9D9),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(
                                Icons.calendar_month,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          //pick time
                          GestureDetector(
                            onTap: _pickTime,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color: const Color(0xffD9D9D9),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(
                                Icons.access_time_filled,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            DateFormat('h:mm a').format(journalEntry!.date),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff009B22),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff747171),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
