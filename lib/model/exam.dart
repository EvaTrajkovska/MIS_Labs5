import 'package:cloud_firestore/cloud_firestore.dart';

class Exam {
  final String name;
  final DateTime date;
  final String time;
  final String uid;
  final String examId;
  final String description;
  bool completed;
  final double latitude;
  final double longitude;

  Exam({
    required this.name,
    required this.date,
    required this.time,
    required this.uid,
    required this.examId,
    required this.description,
    this.completed = false,
    required this.latitude,
    required this.longitude,
  });

  static Exam fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Exam(
      name: snapshot["name"] ?? '',
      date: (snapshot["date"] as Timestamp).toDate(),
      time: snapshot["time"] ?? '',
      uid: snapshot["uid"] ?? '',
      examId: snapshot["examId"] ?? '',
      description: snapshot["description"] ?? '',
      completed: snapshot["completed"] ?? false,
      latitude: snapshot["latitude"] ?? '',
      longitude: snapshot["longitude"] ?? '',


    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "date": Timestamp.fromDate(date),
        "time": time,
        "uid": uid,
        "examId": examId,
        "description": description,
        "completed": completed,
    "latitude": latitude,
    "longitude": longitude,
      };
}
