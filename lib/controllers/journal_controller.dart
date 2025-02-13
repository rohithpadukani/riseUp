import 'package:get/get.dart';
import 'package:riseup/models/journal_model.dart';
import 'package:riseup/services/journal_service.dart';

class JournalController extends GetxController{

  final JournalService _journalService = JournalService();
  final journalEntries = <JournalModel>[].obs;

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