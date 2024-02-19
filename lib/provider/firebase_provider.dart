import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/exam.dart';

class ExamProvider extends ChangeNotifier {
  List<Exam> exams = [];

  void fetchExams() {
    FirebaseFirestore.instance
        .collection('exams')
        .snapshots()
        .listen((snapshot) {
      exams = snapshot.docs.map((doc) => Exam.fromSnap(doc)).toList();
      notifyListeners();
    });
  }

  Future<Exam?> fetchExamById(String examId) async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('exams')
          .doc(examId)
          .get();
      if (doc.exists) {
        return Exam.fromSnap(doc);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> addExam(Exam exam) async {
    try {
      await FirebaseFirestore.instance
          .collection('exams')
          .doc(exam.examId)
          .set(exam.toJson());
      fetchExams();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateExamCompletion(String examId, bool completed) async {
    try {
      await FirebaseFirestore.instance
          .collection('exams')
          .doc(examId)
          .update({'completed': completed});
      fetchExams();
    } catch (e) {
      print(e);
    }
  }

  ExamProvider() {
    fetchExams();
  }
}
