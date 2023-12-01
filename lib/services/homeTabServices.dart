import 'package:http/http.dart' as http;
import 'dart:convert';

class Doctor {
  final int id;
  final String name;
  final String specialization;
  final String latlong;
  final String description;
  final int yoe;
  final String imageUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.latlong,
    required this.description,
    required this.yoe,
    required this.imageUrl,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      specialization: json['specialization'],
      latlong: json['latlong'],
      description: json['description'],
      yoe: json['yoe'],
      imageUrl: json['image_url'],
    );
  }
}

class HomeTabServices {
  static Future<List<Doctor>> fetchDoctors() async {
    final url = Uri.parse('http://0.0.0.0:8000/api/get-doctors');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Doctor> doctors =
        data.map((item) => Doctor.fromJson(item)).toList();
        return doctors;
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load doctors');
    }
  }
}
