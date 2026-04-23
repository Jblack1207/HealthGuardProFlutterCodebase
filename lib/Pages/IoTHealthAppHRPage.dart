import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../Helpers/DeviceViewerHelper.dart';

import 'IoTHealthAppDRVPage.dart';


class Iothealthapphrpage extends StatefulWidget {
  const Iothealthapphrpage({super.key});

  @override
  State<Iothealthapphrpage> createState() => _IothealthapphrpageState();
}

class _IothealthapphrpageState extends State<Iothealthapphrpage> {
  final TextEditingController _deviceIdController = TextEditingController();

  List<dynamic> _devices = [];
  bool _isLoadingDevices = false;
  bool _isAddingDevice = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMyDevices();
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    super.dispose();
  }

  Future<void> _loadMyDevices() async {
    setState(() {
      _isLoadingDevices = true;
      _error = null;
    });

    final result = await DevicePageHelper.loadMyMonitoringDevices();

    if (!mounted) return;

    setState(() {
      _devices = result.devices;
      _error = result.error;
      _isLoadingDevices = false;
    });
  }

  Future<void> _addDevice() async {
    final deviceId = _deviceIdController.text.trim();

    setState(() {
      _isAddingDevice = true;
      _error = null;
    });

    final result = await DevicePageHelper.linkDevice(deviceId);

    if (!mounted) return;

    if (result.success) {
      _deviceIdController.clear();
      await _loadMyDevices();

      if (!mounted) return;

      setState(() {
        _isAddingDevice = false;
      });
    } else {
      setState(() {
        _error = result.error;
        _isAddingDevice = false;
      });
    }
  }
  Future<void> _openDevice(Map<String, dynamic> device) async {
    final deviceId = device['device_id']?.toString() ?? '';
    if (deviceId.isEmpty) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeviceReadingsView(
          deviceId: deviceId,
          deviceName: device['name']?.toString(),
        ),
      ),
    );

    if (!mounted) return;
    await _loadMyDevices();

  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final deviceId = device['device_id']?.toString() ?? 'Unknown device';
    final deviceName = device['name']?.toString() ?? 'Linked Device';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xff27272A),
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
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: () => _openDevice(device),
      ),
    );
  }

  Widget _buildDeviceList() {
    if (_isLoadingDevices) {
      return const Padding(
        padding: EdgeInsets.only(top: 30),
        child: Center(child: CircularProgressIndicator(color: Colors.white,)),
      );
    }

    if (_devices.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xff27272A),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Text(
          'No devices linked yet. Add the device ID you were given to start monitoring.',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: _devices
            .map((device) => _buildDeviceCard(device as Map<String, dynamic>))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
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
              'My Heart-Rate and Fall-Monitor Devices',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your assigned device(s) below, and then revisit its monitoring data anytime.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF27272A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Device',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _deviceIdController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Enter device ID',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xff2D2D31),
                      prefixIcon: const Icon(Icons.memory, color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isAddingDevice ? null : _addDevice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffffc21c).withOpacity(0.95),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isAddingDevice
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,),
                      )
                          : const Text(
                        'Link Device',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  "Failed to add Device. If you believe this is a mistake, please contact the Support Desk",
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 26),
            const Text(
              'Linked Devices',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            _buildDeviceList(),
          ],
        ),
      ),
    );
  }
}
