import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class PushTokenApiHelper {
  static const String baseUrl = 'https://api-appname.duckdns.org/push-tokens';

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

  static Future<void> registerPushToken(
      String pushToken, {
        String? platform,
      }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _headers(),
      body: jsonEncode({
        'push_token': pushToken,
        'platform': platform,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to register push token');
    }
  }
}
