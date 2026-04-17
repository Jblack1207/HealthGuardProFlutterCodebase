import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'APIService.dart';

class FaceUploadApiService {
  final ApiService _base = ApiService();

  Future<Map<String, dynamic>> uploadFaceImages({
    required String deviceId,
    required String personName,
    required List<XFile> files,
  }) async {
    final token = await _base.getValidToken();
    final uri = Uri.parse('${_base.baseUrl}/faces/upload');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['device_id'] = deviceId;
    request.fields['person_name'] = personName;

    for (final file in files) {
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
