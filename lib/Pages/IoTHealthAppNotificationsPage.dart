import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../Helpers/AlertsHelper.dart';
import '../Models/AlertsModel.dart';

class IoTHealthAppNotificationsPage extends StatefulWidget {
  const IoTHealthAppNotificationsPage({super.key});

  @override
  State<IoTHealthAppNotificationsPage> createState() =>
      _IoTHealthAppNotificationsPageState();
}

class _IoTHealthAppNotificationsPageState
    extends State<IoTHealthAppNotificationsPage> {
  bool _isLoading = true;
  String? _error;
  List<AlertModel> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    try {
      final alerts = await AlertApiHelper.fetchAlerts();

      if (!mounted) return;

      setState(() {
        _alerts = alerts;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _acknowledgeAlert(AlertModel alert) async {
    await AlertApiHelper.acknowledgeAlert(alert.id);
    await _loadAlerts();
  }

  Future<void> _resolveAlert(AlertModel alert) async {
    await AlertApiHelper.resolveAlert(alert.id);
    await _loadAlerts();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.greenAccent;
      case 'Acknowledged':
        return const Color(0xffffc21c);
      default:
        return Colors.redAccent;
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xffffffff),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 14,
          ),
        ),
      );
    }

    if (_alerts.isEmpty) {
      return const Center(
        child: Text(
          'No notifications yet',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xffffffff),
      backgroundColor: const Color(0xFF27272A),
      onRefresh: _loadAlerts,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          final alert = _alerts[index];
          final isCritical = alert.severity == 'critical';

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF27272A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isCritical
                    ? Colors.redAccent.withOpacity(0.45)
                    : Colors.white10,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCritical
                          ? Icons.warning_amber_rounded
                          : Icons.notifications_active,
                      color: isCritical
                          ? Colors.redAccent
                          : const Color(0xffffc21c),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        alert.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  alert.message,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Device ID: ${alert.deviceId}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      alert.status,
                      style: TextStyle(
                        color: _statusColor(alert.status),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: alert.status == 'Resolved'
                            ? null
                            : () => _acknowledgeAlert(alert),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffffc21c),
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: Colors.white12,
                          disabledForegroundColor: Colors.white38,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Acknowledge'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: alert.status == 'Resolved'
                            ? null
                            : () => _resolveAlert(alert),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          disabledForegroundColor: Colors.white38,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Resolve'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1F1F1F),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/HGLongLogo.svg',
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Transform.translate(
                    offset: const Offset(-20, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 22,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your latest fall alerts and emergency events',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }
}
