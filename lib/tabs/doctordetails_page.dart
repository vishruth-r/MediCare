import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:medicare/styles/colors.dart';
import 'package:medicare/styles/styles.dart';
import "package:latlong2/latlong.dart" as latLng;

class DoctorDetailPage extends StatelessWidget {
  final Map<String, dynamic> doctorData;

  DoctorDetailPage({required this.doctorData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text('Doctor Details'),
            backgroundColor: Color(MyColors.primary),
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(doctorData['image_url']),
            ),
          ),
          SliverToBoxAdapter(
            child: DetailBody(doctorData: doctorData),
          ),
        ],
      ),
    );
  }
}

class DetailBody extends StatelessWidget {
  final Map<String, dynamic> doctorData;

  DetailBody({required this.doctorData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DetailDoctorCard(doctorData: doctorData),
          SizedBox(height: 15),
          DoctorInfo(doctorData: doctorData),
          SizedBox(height: 30),
          Text(
            'About Doctor',
            style: kTitleStyle,
          ),
          SizedBox(height: 15),
          Text(
            doctorData['description'],
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
          DoctorLocation(),
          SizedBox(height: 25),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Color(MyColors.primary),
              ),
            ),
            child: Text('Book Appointment'),
            onPressed: () {
            },
          ),
        ],
      ),
    );
  }
}

class DoctorLocation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          options: MapOptions(
            center: latLng.LatLng(51.5, -0.09),
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
  final Map<String, dynamic> doctorData;

  DoctorInfo({required this.doctorData});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NumberCard(label: 'Patients', value: '${doctorData['yoe']}+'),
        SizedBox(width: 15),
        NumberCard(
          label: 'Experiences',
          value: '${doctorData['yoe']} years',
        ),
        SizedBox(width: 15),
        NumberCard(label: 'Rating', value: '4.0'),
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
  final Map<String, dynamic> doctorData;

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
                      doctorData['name'],
                      style: TextStyle(
                        color: Color(MyColors.header01),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      doctorData['specialization'],
                      style: TextStyle(
                        color: Color(MyColors.grey02),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Image.network(doctorData['image_url'], width: 100),
            ],
          ),
        ),
      ),
    );
  }
}
