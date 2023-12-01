  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:intl/intl.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import '../constants.dart';
  import '../screens/doctor_detail.dart';
  import '../styles/colors.dart';
  import 'HomeTab.dart';
  import 'login_page.dart';

  class HomePage extends StatefulWidget {
    @override
    _HomePageState createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> {
    List<Map<String, dynamic>> topDoctors = [];
    List<Map<String, dynamic>> myAppointments = [];

    @override
    void initState() {
      super.initState();
      fetchTopDoctors();
      fetchMyAppointments();
    }

    void didChangeDependencies() {
      super.didChangeDependencies();
      fetchMyAppointments();
    }

    Future<void> fetchTopDoctors() async {
      final response = await http.get(Uri.parse('${Constants.apiEndpoint}/api/get-doctors/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> doctors = List<Map<String, dynamic>>.from(data);
        setState(() {
          topDoctors = doctors;
        });
      } else {
        throw Exception('Failed to load top doctors');
      }
    }

    Future<void> fetchMyAppointments() async {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0; // Replace 'userId' with your preference key
      print(userId);
      print("printing userid");
      final response = await http.get(Uri.parse('${Constants.apiEndpoint}/api/user-appointments/$userId/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> appointments = List<Map<String, dynamic>>.from(data);
        setState(() {
          myAppointments = appointments;
        });
      } else {
        throw Exception('Failed to load user appointments');
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('MediCare'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/person.jpeg'),
                    ),
                    Text('Hello'),
                    Text('User Name 👋'),
                  ],
                ),
              ),
              ListTile(
                title: Text('Profile'),
                onTap: () {
                  // Handle profile navigation
                },
              ),
              ListTile(
                title: Text('My Appointments'),
                onTap: () {
                  // Handle my appointments navigation
                },
              ),
              ListTile(
                title: Text('My Orders'),
                onTap: () {
                  // Handle my orders navigation
                },
              ),ListTile(
                title: Text('Logout'),
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); // Clear all data in shared preferences

                  // Navigate to the login page
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
                        (route) => false, // Clear all existing routes
                  );
                },
              ),
            ],
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: ListView(
              children: <Widget>[
                SizedBox(height: 20),
                SearchInput(),
                SizedBox(height: 20),
                CategoryIcons(),
                SizedBox(height: 20),
                if (myAppointments.isNotEmpty)
                  for (int i = 0; i < myAppointments.length; i++)
                    AppointmentCard(
                      onTap: () {
                        // Handle appointment card tap
                      },
                      doctorName: myAppointments[i]['doctor_name'],
                      doctorSpecialization: myAppointments[i]['doctor_specialization'],
                      appointmentDatetime: DateTime.parse(myAppointments[i]['appointment_datetime']),
                      appointmentIndex: i, index: i, // Pass the index to generate the image URL
                      doctorImage: 'assets/doctor0${i + 1}.jpeg',
                    ),
                Text(
                  'Top Doctors',
                  style: TextStyle(
                    color: Color(MyColors.header01),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                for (int i = 0; i < topDoctors.length; i++)
                  TopDoctorCard(
                    doctorName: topDoctors[i]['name'],
                    doctorTitle: topDoctors[i]['specialization'],
                    doctorImage: 'assets/doctor0${i + 1}.jpeg', // Doctor image URL
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }


  class TopDoctorCard extends StatelessWidget {
    String doctorName;
    String doctorTitle;
    final String doctorImage;

    TopDoctorCard({
      required this.doctorName,
      required this.doctorTitle,
      required this.doctorImage,
    });

    @override
    Widget build(BuildContext context) {
      return Card(
        margin: EdgeInsets.only(bottom: 20),
        child: InkWell(
          onTap: () {
            // Handle doctor card tap
            // Navigate to the doctor's detail page and pass the doctor's ID.
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DoctorDetailPage(doctorId: 3),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                color: Color(MyColors.grey01),
                child: Image(
                  width: 100,
                  height:100,
                  image: AssetImage(doctorImage),
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: TextStyle(
                      color: Color(MyColors.header01),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    doctorTitle,
                    style: TextStyle(
                      color: Color(MyColors.grey02),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Color(MyColors.yellow02),
                        size: 18,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '4.0 - 50 Reviews',
                        style: TextStyle(color: Color(MyColors.grey02)),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      );
    }
  }

  class AppointmentCard extends StatelessWidget {
    final void Function() onTap;
    final String doctorName;
    final String doctorSpecialization;
    final DateTime appointmentDatetime;
    final int index;
    final String doctorImage;


    AppointmentCard({
      Key? key,
      required this.onTap,
      required this.index,
      required this.doctorName,
      required this.doctorSpecialization,
      required this.appointmentDatetime,
      required int appointmentIndex,
      required this.doctorImage,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      String formattedDate = DateFormat('dd MMMM yyyy hh:mm a').format(appointmentDatetime);

      return Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(MyColors.primary),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage("assets/doctor02.jpeg"),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doctorName, style: TextStyle(color: Colors.white)),
                              SizedBox(
                                height: 2,
                              ),
                              Text(
                                doctorSpecialization,
                                style: TextStyle(color: Color(MyColors.text01)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Appointment: $formattedDate',
                        style: TextStyle(
                          color: Color(MyColors.text01),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            height: 10,
            decoration: BoxDecoration(
              color: Color(MyColors.bg02),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            width: double.infinity,
            height: 10,
            decoration: BoxDecoration(
              color: Color(MyColors.bg03),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
          ),
        ],
      );
    }
  }

  class SearchInput extends StatelessWidget {
    const SearchInput({
      Key? key,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(MyColors.bg),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Icon(
                Icons.search,
                color: Color(MyColors.purple02),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search a doctor or health issue',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Color(MyColors.purple01),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
