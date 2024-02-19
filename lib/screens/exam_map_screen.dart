import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../model/exam.dart';

class ExamMapScreen extends StatelessWidget {
  final List<Exam> exams;

  const ExamMapScreen({Key? key, required this.exams})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Локации на испити'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(
              41.9981, 21.4254),
          zoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers:
            _buildMarkers(),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    return exams.map((exam) {
      return Marker(
        width: 40.0,
        height: 40.0,
        point:
        LatLng(exam.latitude, exam.longitude),
        child: Icon(
          Icons.location_pin,
          color: Colors.red,
        ),
      );
    }).toList();
  }
}
