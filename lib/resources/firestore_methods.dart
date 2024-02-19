import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../model/exam.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadExam(String name, DateTime date, String time,
      String description, List<String> participants,double latitude,
      double longtitude) async {
    String res = "Some error occurred";
    try {
      String examId = const Uuid().v1();
      Exam exam = Exam(
        name: name,
        date: date,
        time: time,
        description: description,
        uid: FirebaseAuth.instance.currentUser!.uid,
        examId: examId,
        completed: false,
        latitude: latitude,
        longitude: longtitude,
      );
      await _firestore.collection('exams').doc(examId).set(exam.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<List<Exam>> fetchUserExams(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('exams')
          .where('uid', isEqualTo: userId)
          .get();
      return querySnapshot.docs.map((doc) => Exam.fromSnap(doc)).toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<String> updateExamCompletion(String examId, bool completed) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('exams')
          .doc(examId)
          .update({'completed': completed});
      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> deleteExam(String examId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('exams').doc(examId).delete();
      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
