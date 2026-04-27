import 'package:flutter/material.dart';

import 'HRMonitoringChartWidget.dart';

class LatestMonitoringSection extends StatefulWidget {
  final List<dynamic> devices;
  final Future<List<dynamic>> Function(String deviceId) getReadings;

  const LatestMonitoringSection({
    super.key,
    required this.devices,
    required this.getReadings,

  });

  @override
  State<LatestMonitoringSection> createState() => _LatestMonitoringSectionState();
}

class _LatestMonitoringSectionState extends State<LatestMonitoringSection> {
  Map<String, dynamic>? _selectedDevice;
  Map<String, dynamic>? _latestReading;
  bool _isLoading = false;
  String? _error;
  List<dynamic> _readings = [];

  List<Map<String, dynamic>> get _monitoringDevices {
    return widget.devices
        .where((device) {
      final map = device as Map<String, dynamic>;
      final type = map['device_type'];
      return type == 1 || type == 2;
    })
        .map((device) => device as Map<String, dynamic>)
        .toList();
  }


  Future<void> _loadReadings() async {
    final device = _selectedDevice;
    if (device == null) return;

    final deviceId = device['device_id']?.toString();
    if (deviceId == null || deviceId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _latestReading = null;
      _readings = [];
    });

    try {
      final readings = await widget.getReadings(deviceId);

      if (!mounted) return;

      setState(() {
        _readings = readings;
        _latestReading = readings.isEmpty
            ? null
            : readings.first as Map<String, dynamic>;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load readings: $e';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant LatestMonitoringSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_selectedDevice == null && _monitoringDevices.isNotEmpty) {
      _selectedDevice = _monitoringDevices.first;
      _loadReadings();
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_monitoringDevices.isEmpty) {
      return const Text(
        'No monitoring devices linked.',
        style: TextStyle(color: Colors.white70),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_error != null) {
      return Text(
        _error!,
        style: const TextStyle(color: Colors.redAccent),
      );
    }

    if (_latestReading == null) {
      return const Text(
        'No readings available.',
        style: TextStyle(color: Colors.white70),
      );
    }

    return Column(
      children: [
        _infoRow('Heart Rate', '${_latestReading!['heart_rate'] ?? '-'} bpm'),
        _infoRow('SpO2', '${_latestReading!['spo2'] ?? '-'} %'),
        _infoRow('Temperature', '${_latestReading!['temperature'] ?? '-'} C'),
        _infoRow('Recorded At', _latestReading!['created_at']?.toString() ?? '-'),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    if (_monitoringDevices.isNotEmpty) {
      _selectedDevice = _monitoringDevices.first;
      _loadReadings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xaa27272A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Latest HR Monitoring Results',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w200,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xff2B2B30),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedDevice?['device_id']?.toString(),
              dropdownColor: const Color(0xff2B2B30),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xff2B2B30),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _monitoringDevices.map((device) {
                final deviceId = device['device_id']?.toString() ?? '';
                final deviceName = device['name']?.toString() ?? deviceId;

                return DropdownMenuItem<String>(
                  value: deviceId,
                  child: Text(
                    deviceName,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedDevice = _monitoringDevices.firstWhere(
                        (device) => device['device_id']?.toString() == value,
                  );
                });

                _loadReadings();
              },
            ),
          ),
          const SizedBox(height: 18),
          _buildContent(),
          const SizedBox(height: 18),
          HRLineChart(readings: _readings),
        ],
      ),
    );
  }
}
