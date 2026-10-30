
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // For Flutter Web or a Mac desktop app running on this same Mac.
  static const String baseUrl = 'http://192.168.29.21:4000/api';

  static Future<List<dynamic>> getHospitals() async {
    final uri = Uri.parse('$baseUrl/hospitals');

    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['hospitals'] as List<dynamic>;
      }

      throw Exception(
        'Failed to load hospitals: HTTP ${response.statusCode}',
      );
    } catch (e) {
      throw Exception('Could not fetch hospitals: $e');
    }
  }
}
