import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riseup/models/journal_model.dart';

class JournalService {

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //save journal entry  
  Future<void> saveJournalEntry(JournalModel entry) async {
    try{
      await _fireStore.collection('journal').add(entry.toJson());
    }catch(e){
      throw Exception('Failed to save habit: $e');
    }
  }

  //retrieve journal entries
  Future<List<JournalModel>> getAllEntries() async{
    try{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('journal').get();
      return querySnapshot.docs.map(
        (doc) => JournalModel.fromJson(doc.data() as Map<String, dynamic>)
      ).toList();
    }catch(e){
      throw Exception();
    }
  }

}