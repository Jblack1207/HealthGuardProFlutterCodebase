import 'dart:convert';
import 'APIService.dart';


class UsersAPIService {
  final ApiService _base = ApiService();


  Future<Map<String, dynamic>> getMe() async {
    final response = await _base.authorizedGet('/auth/me');

    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> syncUser(String username, String firstName, String lastName) async {
    final response = await _base.authorizedPost(
      '/auth/sync',
      body: {
        'username': username,
        'first_name': firstName,
        'last_name': lastName
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<String?> getCurrentUserFirstName() async {
    final user = await getMe();
    final firstName = user['first_name']?.toString().trim();

    print(firstName);

    if (firstName == null || firstName.isEmpty) {
      return null;
    }

    return firstName;
  }


}



