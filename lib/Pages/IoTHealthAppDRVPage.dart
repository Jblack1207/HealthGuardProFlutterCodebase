import 'package:flutter/material.dart';
import '../Helpers/DevicesAPIService.dart';

class DeviceReadingsView extends StatefulWidget {
  final String deviceId;

  const DeviceReadingsView({
    super.key,
    required this.deviceId,
  });

  @override
  State<DeviceReadingsView> createState() => _DeviceReadingsViewState();
}

class _DeviceReadingsViewState extends State<DeviceReadingsView> {
  List<dynamic> _readings = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDeviceReadings();
  }

  Future<void> _loadDeviceReadings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final readings =
      await DeviceApiService().getHRDeviceReadings(widget.deviceId);

      setState(() {
        _readings = readings;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load readings: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  Widget _buildReadingCard(Map<String, dynamic> reading) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff27272A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _infoRow('Heart Rate', '${reading['heart_rate'] ?? '-'} bpm'),
          _infoRow('SpO2', '${reading['spo2'] ?? '-'} %'),
          _infoRow('Temperature', '${reading['temperature'] ?? '-'} C'),
          _infoRow('Recorded At', reading['created_at']?.toString() ?? '-'),
        ],
      ),
    );
  }

  Widget _buildReadingsContent() {
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

    if (_readings.isEmpty) {
      return const Center(
        child: Text(
          'No monitoring data found for this device',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final latestReading = _readings.first as Map<String, dynamic>;
    final historyReadings = _readings.length > 1 ? _readings.sublist(1) : [];

    return RefreshIndicator(
      color: Colors.white,
      onRefresh: _loadDeviceReadings,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Latest',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildReadingCard(latestReading),
          const SizedBox(height: 12),
          const Text(
            'History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (historyReadings.isEmpty)
            const Text(
              'No previous readings available',
              style: TextStyle(color: Colors.white70),
            )
          else
            ...historyReadings.map(
                  (reading) => _buildReadingCard(
                reading as Map<String, dynamic>,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xff1F1F1F),
        title: Text('Device ${widget.deviceId}'),
      ),
      body: _buildReadingsContent(),
    );
  }
}
