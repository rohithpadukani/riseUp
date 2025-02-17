import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:riseup/models/journal_model.dart';

class JournalService {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  User? user = FirebaseAuth.instance.currentUser;

  //save journal entry to firestore
  Future<void> saveJournalEntry(JournalModel entry) async {
    if (user != null) {
      _fireStore
          .collection('journals')
          .doc(user!.uid)
          .collection('entries')
          .add(entry.toJson());
    }
  }

  //update journal entry
  Future<void> updateJournalEntry(String userId, String docId, String newTitle,
      String newDescription, Timestamp newDate) async {
    if (user != null) {
      _fireStore
          .collection('journals')
          .doc(user!.uid)
          .collection('entries')
          .doc(docId)
          .update({
        'title': newTitle,
        'description': newDescription,
        'date': newDate,
      });
    } else {
      print("No user is logged in.");
    }
  }

  //retrieve all journal entries from firestore
  //not necessarily used, bacause streams are used to fetch data in journal page
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

  //delete journal from firestore
  Future<void> deleteJournalEntry(String userId, String docId) async {
    await FirebaseFirestore.instance
        .collection('journals')
        .doc(userId)
        .collection('entries')
        .doc(docId)
        .delete();
  }

  // //fetch single entry from firestore
  // Future<Map<String, dynamic>> fetchSingleEntry(
  //     String userId, String docId) async {
  //   DocumentSnapshot doc = await _fireStore
  //       .collection('journals')
  //       .doc(userId)
  //       .collection('entries')
  //       .doc(docId)
  //       .get();
  //   if (doc.exists) {
  //     return doc.data() as Map<String, dynamic>;
  //   } else {
  //     throw Exception('Entry not found');
  //   }
  // }

  //fetch single entry from firestore as object
  Future<JournalModel?> getEntry(String userId, String docId) async {
    DocumentSnapshot doc = await _fireStore.collection('journals').doc(userId).collection('entries').doc(docId).get();
    if(doc.exists){
      return JournalModel.fromJson((doc.data() as Map<String, dynamic>), docId);
    }else {
      return null;
    }
  }
}
