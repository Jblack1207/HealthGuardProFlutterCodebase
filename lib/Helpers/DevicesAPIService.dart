import 'dart:convert';
import 'APIService.dart';

class DeviceApiService {
  final ApiService _base = ApiService();

  Future<List<dynamic>> getMyDevices({int? deviceType}) async {
    final path = deviceType == null
        ? '/devices/mine'
        : '/devices/mine?device_type=$deviceType';

    final response = await _base.authorizedGet(path);

    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<void> linkDevice(String deviceId) async {
    final response = await _base.authorizedPost(
      '/devices/link',
      body: {
        'device_id': deviceId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<dynamic>> getHRDeviceReadings(String deviceId) async {
    final encodedDeviceId = Uri.encodeComponent(deviceId);
    final response = await _base.authorizedGet('/heart-rate-monitor/reading?device_id=$encodedDeviceId');

    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }


}
