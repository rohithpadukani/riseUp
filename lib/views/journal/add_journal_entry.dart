import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:riseup/controllers/journal_controller.dart';
import 'package:riseup/models/journal_model.dart';

class AddJournalPage extends StatefulWidget {

  const AddJournalPage({super.key});

  @override
  State<AddJournalPage> createState() => _AddJournalPageState();
}

class _AddJournalPageState extends State<AddJournalPage> {

  final JournalController _journalController = Get.put(JournalController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  //save the new journal entry
  void _saveJournalEntry() {

    DateTime finalDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute
    );

    final entry = JournalModel(
        docId: '',
        date: finalDateTime,
        title: _titleController.text,
        description: _descriptionController.text);

    _journalController.saveJournalEntry(entry);
  }

  DateTime selectedTime = DateTime.now();
  DateTime selectedDate = DateTime.now();

  //method to pick time
  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedTime),
    );
    if (pickedTime != null) {
      setState(() {
        DateTime now = DateTime.now();
        selectedTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      });
    }
  }

  //method to pick date
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Entry',
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
              fontFamily: 'assets/fonts/Inter-Regular.ttf'),
        ),
        actions: [
          //close icon to go back
          IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.close,
              size: 35,
              color: Colors.red,
            ),
          ),
          //check button to save entry
          IconButton(
            onPressed: () {
              _saveJournalEntry();
            },
            icon: const Icon(
              weight: 500,
              Icons.check,
              size: 35,
              color: Color(0xff009B22),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      body: Container(
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
                    //display month and date
                    Text(
                      DateFormat('MMMM d').format(selectedDate),
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff434343),
                      ),
                    ),
                    //display day and year
                    Text(
                      DateFormat('EEEE, yyyy').format(selectedDate),
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
                    //display time
                    Text(
                      DateFormat('h:mm a').format(selectedTime),
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
            //title input
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(      
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff747171),
                ),
                border: InputBorder.none,
              ),
            ),
            //description input
            Expanded(
              child: TextField(
                controller: _descriptionController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Write here',
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
