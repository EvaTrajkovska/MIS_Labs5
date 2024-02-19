import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laboratoriska3/model/exam.dart';

import '../main.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<Exam>> _examEvents = {};
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _fetchExams();
  }

  void _fetchExams() async {
    if (currentUserId != null) {
      FirebaseFirestore.instance
          .collection('exams')
          .where('uid', isEqualTo: currentUserId)
          .snapshots()
          .listen((snapshot) {
        Map<DateTime, List<Exam>> newExamEvents = {};
        for (var doc in snapshot.docs) {
          Exam exam = Exam.fromSnap(doc);
          DateTime examDate =
              DateTime(exam.date.year, exam.date.month, exam.date.day);
          if (newExamEvents[examDate] == null) newExamEvents[examDate] = [];
          newExamEvents[examDate]!.add(exam);
        }
        setState(() {
          _examEvents = newExamEvents;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exam Calendar"),
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _showExamsForSelectedDay(selectedDay);
        },
        eventLoader: (day) {
          return _examEvents[day] ?? [];
        },
      ),
    );
  }

  void _showExamsForSelectedDay(DateTime selectedDay) {
    DateTime normalizedSelectedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    var examsForSelectedDay = _examEvents[normalizedSelectedDay] ?? [];
    if (examsForSelectedDay.isEmpty) {
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: examsForSelectedDay.length,
          itemBuilder: (context, index) {
            Exam exam = examsForSelectedDay[index];
            return ListTile(
              title: Text(exam.name),
              subtitle: Text(
                  "${exam.date.day}.${exam.date.month}.${exam.date.year}, ${exam.time}"),
            );
          },
        );
      },
    );
  }
}
