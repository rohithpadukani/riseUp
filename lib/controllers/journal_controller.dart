import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:riseup/models/journal_model.dart';
import 'package:riseup/services/journal_service.dart';

class JournalController extends GetxController{

  final JournalService _journalService = JournalService();
  final journalEntries = <JournalModel>[].obs;
  User? user = FirebaseAuth.instance.currentUser;

  //save journal entry
  Future<void> saveJournalEntry(JournalModel entry) async {
    try{
      await _journalService.saveJournalEntry(entry);
      journalEntries.add(entry);
      Get.back();
      Get.snackbar('Success', 'Journal entry added successfully!');
    }catch(e){
      Get.snackbar('Failed', 'Journal entry adding failed');
    }
  }

  //update journal entry
  Future<void> updateJournalEntry(String userId, String docId, String newTitle, String newDescription) async{
    try{
      await _journalService.updateJournalEntry(userId, docId, newTitle, newDescription);
      Get.back();
      Get.snackbar('Success', 'Journal entry edited successfully!');
    }catch(e){
      Get.snackbar('Failed', 'Failed to update entry');
    }
  }

  

  //fetch entries
  Future<void> getAllEntries() async{
    try{
      await _journalService.getAllEntries();
      Get.snackbar('Success', 'Successfully fetched');
    }catch(e){
      print(e);
    }

  }

}