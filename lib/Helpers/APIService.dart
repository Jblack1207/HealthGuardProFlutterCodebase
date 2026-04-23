import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;


class ApiService {
  final String baseUrl = 'https://api-appname.duckdns.org';

  Future<String> getValidToken({bool forceRefresh = false}) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No logged-in Firebase user');
    }

    final token = await user.getIdToken(forceRefresh);

    if (token == null || token.isEmpty) {
      throw Exception('Failed to get Firebase token');
    }

    return token;
  }

  Future<http.Response> authorizedGet(String path) async {
    String token = await getValidToken();

    http.Response response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 401) {
      token = await getValidToken(forceRefresh: true);

      response = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    }

    return response;
  }

  Future<http.Response> authorizedPost(
      String path, {
        Map<String, dynamic>? body,
      }) async {
    String token = await getValidToken();

    http.Response response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401) {
      token = await getValidToken(forceRefresh: true);

      response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body != null ? jsonEncode(body) : null,
      );
    }

    return response;
  }

  Future<http.Response> authorizedPatch(
      String path, {
        Map<String, dynamic>? body,
      }) async {
    String token = await getValidToken();

    http.Response response = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401) {
      token = await getValidToken(forceRefresh: true);

      response = await http.patch(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body != null ? jsonEncode(body) : null,
      );
    }

    return response;
  }


}



