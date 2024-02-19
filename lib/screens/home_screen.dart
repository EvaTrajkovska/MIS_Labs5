import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../model/exam.dart';
import '../resources/firestore_methods.dart';
import 'calendar_screen.dart';
import 'exam_map_screen.dart';
import 'location_picker_screen.dart';
import 'login_screen.dart';
import 'package:latlong2/latlong.dart';



class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Exam> exams = [];
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreMethods _firestoreMethods = FirestoreMethods();
  String currentUserId = "";
  double _selectedLatitude = 0.0;
  double _selectedLongitude = 0.0;

  Future<void> _addExam() async {
    final TextEditingController _subjectController = TextEditingController();
    DateTime? _selectedDate;
    TimeOfDay? _selectedTime;
    if (!mounted) return;

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
      );
      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
        });
      }
    }

    Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null && picked != _selectedTime) {
        setState(() {
          _selectedTime = picked;
        });
      }
    }
    Future<void> signOut() async{
     await FirebaseAuth.instance.signOut();
   }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Додади нов колоквиум'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _subjectController,
                  decoration: const InputDecoration(labelText: 'Предмет'),
                ),
                ListTile(
                  title: Text(_selectedDate == null
                      ? 'Избери датум'
                      : 'Датум: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
                ListTile(
                  title: Text(_selectedTime == null
                      ? 'Избери време'
                      : 'Време: ${_selectedTime!.format(context)}'),
                  trailing: Icon(Icons.access_time),
                  onTap: () => _selectTime(context),
                ),
                ListTile(
                  title: const Text('Избери локација на мапа'),
                  trailing: const Icon(Icons.map),
                  onTap: () async {
                    final LatLng? pickedLocation =
                    await Navigator.of(context).push<LatLng>(
                      MaterialPageRoute(
                          builder: (context) => LocationPickerScreen()),
                    );
                    if (pickedLocation != null) {
                      setState(() {
                        _selectedLatitude = pickedLocation.latitude;
                        _selectedLongitude = pickedLocation.longitude;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Откажи'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Зачувај'),
              onPressed: () async {
                if (_selectedDate != null &&
                    _selectedTime != null &&
                    _subjectController.text.isNotEmpty) {
                  final DateTime examDateTime = DateTime(
                    _selectedDate!.year,
                    _selectedDate!.month,
                    _selectedDate!.day,
                    _selectedTime!.hour,
                    _selectedTime!.minute,
                  );
                  final String result = await _firestoreMethods.uploadExam(
                    _subjectController.text,
                    examDateTime,
                    DateFormat('HH:mm').format(examDateTime),
                    "", // Description
                    [],
                    _selectedLatitude,
                    _selectedLongitude,
                  );

                  if (result == "success") {
                    if(exams!=[]){
                    _scheduleNotification(exams.last);}
                    setState(() {
                      exams.add(exams.last);
                      _selectedDate = null;
                      _selectedTime = null;
                    });
                    Navigator.of(context).pop();
                  } else {}
                } else {}

                _subjectController.clear();
                fetchExams();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          currentUserId = user.uid;
        });
        fetchExams();
      }
    });
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(Exam exam) async {
    DateTime notificationTime = exam.date.subtract(const Duration(minutes: 5));

    var androidDetails = const AndroidNotificationDetails(
      'exam_id',
      'Exam Notifications',
      channelDescription: 'Notification channel for exam reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSDetails = IOSNotificationDetails();
    var platformDetails = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await flutterLocalNotificationsPlugin.schedule(
      exam.hashCode,
      'Exam Reminder',
      '${exam.name} is scheduled for ${exam.time}',
      //examTime,
      notificationTime,
      platformDetails,
    );
  }


  void getCurrentUserAndFetchData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
      fetchExams();
    }
  }

  void fetchExams() {
   // if (!mounted) return;

    _firestore
        .collection('exams')
        .where('uid', isEqualTo: currentUserId)
        .orderBy('date')
        .snapshots()
        .listen((snapshot) {
      print("Fetched ${snapshot.docs.length} exams.");
      setState(() {
        exams = snapshot.docs.map((doc) => Exam.fromSnap(doc)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple[300],
        title: const Text('Листа на колоквиуми'),
        titleTextStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black,),
            onPressed: _addExam,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined,color: Colors.black,),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CalendarScreen()),
              );
            },
          ),
          IconButton(onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ExamMapScreen(exams: exams,)),
            );
          }, icon: const Icon(Icons.map, color: Colors.black,)),
            IconButton(
            icon: const Icon(Icons.exit_to_app_outlined,color: Colors.black,),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        itemCount: exams.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (ctx, i) => Card(
          color: Colors.purple[100],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                exams[i].name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              Text(
                "${exams[i].date.day}.${exams[i].date.month}.${exams[i].date.year}, ${exams[i].time}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
