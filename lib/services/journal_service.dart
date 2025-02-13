import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:riseup/models/journal_model.dart';

class JournalService {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  //save journal entry
  Future<void> saveJournalEntry(JournalModel entry) async {
    if (user != null) {
      _fireStore
          .collection('journals')
          .doc(user!.uid)
          .collection('entries')
          .add(entry.toJson());
    } else {
      Get.snackbar('No User', 'No user has logged in!');
    }
  }

  //update journal entry
  Future<void> updateJournalEntry(String userId, String docId, String newTitle,
      String newDescription) async {
    if (user != null) {
      _fireStore
          .collection('journals')
          .doc(user!.uid)
          .collection('entries')
          .doc(docId)
          .update({
        'title': newTitle,
        'description': newDescription,
        'date': Timestamp.now(),
      });
    } else {
      print("No user is logged in.");
    }
  }

  //retrieve journal entries
  Future<List<JournalModel>> getAllEntries() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('journal').get();
      return querySnapshot.docs
          .map((doc) =>
              JournalModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception();
    }
  }
}
