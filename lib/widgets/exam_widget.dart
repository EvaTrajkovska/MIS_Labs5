import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/exam.dart';

class ExamTile extends StatelessWidget {
  final Exam exam;

  const ExamTile({Key? key, required this.exam}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _launchMapsUrl(exam.latitude, exam.longitude);
      },
      child: Card(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              exam.name,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            Text(
              "${exam.date.day}.${exam.date.month}.${exam.date.year}, ${exam.time}",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchMapsUrl(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
