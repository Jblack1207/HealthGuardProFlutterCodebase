import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../Helpers/DeviceViewerHelper.dart';
import 'IoTHealthAppCamPageViewer.dart';

class IoTHealthAppCamPage extends StatefulWidget {
  const IoTHealthAppCamPage({super.key});

  @override
  State<IoTHealthAppCamPage> createState() => _IoTHealthAppCamPageState();
}

class _IoTHealthAppCamPageState extends State<IoTHealthAppCamPage> {
  List<dynamic> _devices = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMyDevices();
  }

  Future<void> _loadMyDevices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await DevicePageHelper.loadMyCamDevices();

    if (!mounted) return;

    setState(() {
      _devices = result.devices;
      _error = result.error;
      _isLoading = false;
    });
  }

  void _openCameraForDevice(Map<String, dynamic> device) {
    final deviceId = device['device_id']?.toString() ?? '';

    if (deviceId.isEmpty) {
      setState(() {
        _error = 'This device does not have a valid device ID';
      });
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IoTHealthAppCamPageViewer(deviceId: deviceId),
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final deviceId = device['device_id']?.toString() ?? 'Unknown device';
    final deviceName = device['name']?.toString() ?? 'Linked Device';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF27272A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        title: Text(
          deviceName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            'Device ID: $deviceId',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        trailing: const Icon(Icons.videocam, color: Colors.white70),
        onTap: () => _openCameraForDevice(device),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    if (_devices.isEmpty) {
      return const Center(
        child: Text(
          'No linked devices found.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.white,
      onRefresh: _loadMyDevices,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 130),
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/images/HGLongLogo.svg',
              width: 200,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Camera Feed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select one of your linked Camera devices to open its live camera feed.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ..._devices.map((device) => _buildDeviceCard(device as Map<String, dynamic>)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: _buildBody());
  }
}
