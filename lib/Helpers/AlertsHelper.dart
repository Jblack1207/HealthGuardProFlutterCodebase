import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../Models/AlertsModel.dart';

class AlertApiHelper {
  static const String baseUrl = 'https://api-appname.duckdns.org/alerts';

  static Future<Map<String, String>> _headers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No logged in user');
    }

    final token = await user.getIdToken(true);

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<List<AlertModel>> fetchAlerts() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load alerts');
    }

    final decoded = jsonDecode(response.body) as List;
    return decoded.map((e) => AlertModel.fromJson(e)).toList();
  }

  static Future<List<AlertModel>> fetchActiveAlerts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/active'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load active alerts');
    }

    final decoded = jsonDecode(response.body) as List;
    return decoded.map((e) => AlertModel.fromJson(e)).toList();
  }

  static Future<void> acknowledgeAlert(int alertId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$alertId/acknowledge'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to acknowledge alert');
    }
  }

  static Future<void> resolveAlert(int alertId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$alertId/resolve'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to resolve alert');
    }
  }
}
