import 'package:flutter/material.dart';

class DeviceTypeSummaryWidget extends StatelessWidget {
  final List<dynamic> devices;

  const DeviceTypeSummaryWidget({
    super.key,
    required this.devices,
  });

  int _countByType(int type) {
    return devices.where((device) {
      final map = device as Map<String, dynamic>;
      return map['device_type'] == type;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final totalDevices = devices.length;
    final cameraDevices = _countByType(3);
    final monitoringDevices = _countByType(2) + _countByType(1);
    final otherDevices = totalDevices - cameraDevices - monitoringDevices;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xaa27272A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Devices',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  label: 'Total',
                  value: totalDevices.toString(),
                  color: const Color(0xffffc21c),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  label: "Camera's",
                  value: cameraDevices.toString(),
                  color: const Color(0xff4FC3F7),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  label: 'Monitors',
                  value: monitoringDevices.toString(),
                  color: const Color(0xff81C784),
                ),
              ),
            ],
          ),
          if (otherDevices > 0) ...[
            const SizedBox(height: 12),
            _summaryCard(
              label: 'Other',
              value: otherDevices.toString(),
              color: const Color(0xffBA68C8),
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String label,
    required String value,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xff2B2B30),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w200,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
