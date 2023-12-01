import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:medicare/styles/colors.dart';
import 'package:medicare/styles/styles.dart';
import "package:latlong2/latlong.dart" as latLng;
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class DoctorDetailPage extends StatelessWidget {
  final int doctorId;

  DoctorDetailPage({required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text('Doctor Detail'),
            backgroundColor: Color(MyColors.primary),
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset('assets/hospital.jpeg'), // Set a placeholder image URL
            ),
          ),
          SliverToBoxAdapter(
            child: DetailBody(doctorId: doctorId),
          ),
        ],
      ),
    );
  }
}

class DetailBody extends StatefulWidget {
  final int doctorId;

  DetailBody({required this.doctorId});

  @override
  _DetailBodyState createState() => _DetailBodyState();
}

class _DetailBodyState extends State<DetailBody> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<DoctorDetails>(
            future: fetchDoctorDetails(widget.doctorId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                return Column(
                  children: [
                    DetailDoctorCard(
                      doctorData: snapshot.data as DoctorDetails,
                    ),
                    SizedBox(height: 15),
                    DoctorInfo(doctorData: snapshot.data as DoctorDetails),
                    SizedBox(height: 30),
                    Text(
                      'About Doctor',
                      style: kTitleStyle,
                    ),
                    SizedBox(height: 15),
                    Text(
                      snapshot.data?.description ?? 'Description not available',
                      style: TextStyle(
                        color: Color(MyColors.purple01),
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 25),
                    Text(
                      'Location',
                      style: kTitleStyle,
                    ),
                    SizedBox(height: 25),
                    DoctorLocation(latLong: '22.5726, 88.3639',),
                    SizedBox(height: 25),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color(MyColors.primary),
                        ),
                      ),
                      child: Text('Book Appointment'),
                      onPressed: () {
                        _showDatePicker(context);
                      },
                    ),
                  ],
                );
              } else {
                return Text('No data available.');
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );

    if (pickedDate != null) {
      _showTimePicker(context, pickedDate);
    }
  }

  void _showTimePicker(BuildContext context, DateTime selectedDate) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      DateTime selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      _scheduleAppointment(selectedDateTime);
    }
  }

  void _scheduleAppointment(DateTime selectedDateTime) async {
    final int doctorId = widget.doctorId; // Actual doctor ID
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int patientId = prefs.getInt('user_id') ?? 2;
    print(patientId);
    print("works till here");
    final formattedDateTime = selectedDateTime.toUtc().toIso8601String();

    final Map<String, dynamic> requestBody = {
      "doctor": doctorId,
      "patient": patientId,
      "appointment_datetime": formattedDateTime,
    };

    try {
      final response = await http.post(
        Uri.parse('${Constants.apiEndpoint}/api/book-appointment/'), // Replace with your actual API endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Appointment scheduled successfully, handle the response if needed
        print('Appointment scheduled successfully');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Appointment Scheduled')
            )
        );

      } else {
        // Failed to schedule appointment, handle the error
        print('Failed to schedule appointment. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network errors or other exceptions
      print('Error scheduling appointment: $error');
    }
  }
}

class DoctorLocation extends StatelessWidget {
  final String latLong; // Pass the latlong from the doctor's data

  DoctorLocation({required this.latLong});

  @override
  Widget build(BuildContext context) {
    final latLongList = latLong.split(','); // Split the latlong into latitude and longitude
    final latitude = double.parse(latLongList[0]);
    final longitude = double.parse(latLongList[1]);

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          options: MapOptions(
            center: latLng.LatLng(latitude, longitude), // Set the center using latitude and longitude
            zoom: 13.0,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorInfo extends StatelessWidget {
  final DoctorDetails doctorData;

  DoctorInfo({required this.doctorData});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NumberCard(label: 'Patients', value: '300+'),
        SizedBox(width: 15),
        NumberCard(
          label: 'Experiences',
          value: '${doctorData.yoe} years',
        ),
        SizedBox(width: 15),
        NumberCard(label: 'Rating', value: '5'),
      ],
    );
  }
}



class NumberCard extends StatelessWidget {
  final String label;
  final String value;

  NumberCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(MyColors.bg03),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 15,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Color(MyColors.grey02),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: Color(MyColors.header01),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailDoctorCard extends StatelessWidget {
  final DoctorDetails doctorData;

  DetailDoctorCard({required this.doctorData});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: EdgeInsets.all(15),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorData.name,
                      style: TextStyle(
                        color: Color(MyColors.header01),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      doctorData.specialization,
                      style: TextStyle(
                        color: Color(MyColors.grey02),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset("assets/doctor02.jpeg", width: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class DoctorDetails {
  final String name;
  final String specialization;
  final String description;
  final String imageURL;
  final int yoe;

  DoctorDetails({
    required this.name,
    required this.specialization,
    required this.description,
    required this.imageURL,
    required this.yoe,
  });
}

Future<DoctorDetails> fetchDoctorDetails(int doctorId) async {
  final response = await http.get(Uri.parse('${Constants.apiEndpoint}/api/get-doctors/3'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return DoctorDetails(
      name: jsonData['name'],
      specialization: jsonData['specialization'],
      description: jsonData['description'],
      imageURL: jsonData['image_url'],
      yoe: jsonData['yoe'],
    );
  } else {
    throw Exception('Failed to load doctor details');
  }
}
void main() {
  runApp(MaterialApp(
    home: DoctorDetailPage(doctorId: 1), // Pass the doctor ID you want to display
  ));
}
