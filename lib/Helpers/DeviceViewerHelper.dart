import 'DevicesAPIService.dart';

class DeviceLoadResult {
  final List<dynamic> devices;
  final String? error;

  DeviceLoadResult({
    required this.devices,
    this.error,
  });
}

class DeviceActionResult {
  final bool success;
  final String? error;

  DeviceActionResult({
    required this.success,
    this.error,
  });
}

class DevicePageHelper {
  static Future<DeviceLoadResult> loadMyMonitoringDevices() async {
    try {
      final devicesHR = await DeviceApiService().getMyDevices(deviceType: 1);
      final devicesFD = await DeviceApiService().getMyDevices(deviceType: 2);

      final devices = <dynamic>[
        ...devicesHR,
        ...devicesFD,
      ];
      return DeviceLoadResult(devices: devices);
    } catch (e) {
      return DeviceLoadResult(
        devices: [],
        error: 'Failed to load devices: $e',
      );
    }
  }
  static Future<DeviceLoadResult> loadMyCamDevices() async {
    try {
      final devicesHR = await DeviceApiService().getMyDevices(deviceType: 3);

      final devices = devicesHR;
      return DeviceLoadResult(devices: devices);
    } catch (e) {
      return DeviceLoadResult(
        devices: [],
        error: 'Failed to load devices: $e',
      );
    }
  }

  static Future<DeviceActionResult> linkDevice(String deviceId) async {
    if (deviceId.isEmpty) {
      return DeviceActionResult(
        success: false,
        error: 'Please enter a device ID',
      );
    }

    try {
      await DeviceApiService().linkDevice(deviceId);
      return DeviceActionResult(success: true);
    } catch (e) {
      return DeviceActionResult(
        success: false,
        error: 'Failed to add device: $e',
      );
    }
  }
  static Future<DeviceLoadResult> loadMyDevices() async {
    try {
      final devices = await DeviceApiService().getMyDevices();

      return DeviceLoadResult(devices: devices);
    } catch (e) {
      return DeviceLoadResult(
        devices: [],
        error: 'Failed to load devices: $e',
      );
    }
  }
}
