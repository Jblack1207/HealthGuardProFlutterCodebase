//BCB Homepage
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iot_app_project/Firebase Helpers/FirebaseAuth Helper.dart';
import 'package:iot_app_project/Helpers/UsersAPIService.dart';


import '../Helpers/DeviceViewerHelper.dart';
import '../Helpers/DevicesAPIService.dart';
import '../Helpers/LatestMonitoringWidget.dart';
import '../Helpers/TotalDevicesWidget.dart';
import '../pages/IoTHealthAppLoginPage.dart';

class IoTHealthAppHomePage extends StatefulWidget {
  const IoTHealthAppHomePage({super.key});


  @override
  State<IoTHealthAppHomePage> createState() =>
      _IoTHealthAppHomePageState();
}


///class state definitions and logic control
class _IoTHealthAppHomePageState
    extends State<IoTHealthAppHomePage> {
  String? firstName;
  final ScrollController _scrollController = ScrollController();

  Future<void> _loadFirstName() async {
    final name = await UsersAPIService().getCurrentUserFirstName();

    setState(() {
      firstName = name;
    });
  }

  List<dynamic> _devices = [];
  List<dynamic> _Mondevices = [];


  @override
  void initState() {
    super.initState();
    _loadFirstName();
    _loadDevices();
    _loadMonitoringDevices();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    setState(() {
    });

    final result = await DevicePageHelper.loadMyDevices();

    if (!mounted) return;

    setState(() {
      _devices = result.devices;
    });
  }

  Future<void> _loadMonitoringDevices() async {
    setState(() {
    });

    final result = await DevicePageHelper.loadMyMonitoringDevices();

    if (!mounted) return;

    setState(() {
      _Mondevices = result.devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 18,
          left: 18,
          right: 18,
          bottom: 130,
        ),
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
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                           IconButton(
                            onPressed: () async {
                              await AuthService().signOut();
                              final user = FirebaseAuth.instance.currentUser;
                              debugPrint('Current user after logout: $user');

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const IoTHealthAppLoginScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.account_circle,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 0),
                          firstName == null
                              ? const Text(
                            'Welcome',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                              : RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Welcome, ',
                                  style: TextStyle(color: Colors.white, fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: firstName,
                                  style: const TextStyle(
                                      color: Color(0xffffc21c),
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 126),//need to fix in relation to different sized names //TODO
                          const Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 34,
                          ),
                        ]
                    ),
                    const SizedBox(height: 18),
                    DeviceTypeSummaryWidget(devices: _devices),

                    const SizedBox(height: 18),

                    LatestMonitoringSection(
                      devices: _Mondevices,
                      getLatestReading: (deviceId) async {
                        final readings = await DeviceApiService().getHRDeviceReadings(deviceId);

                        if (readings.isEmpty) {
                          return null;
                        }

                        return readings.first as Map<String, dynamic>;
                      },
                    ),

                  ]
              )
            ]
        )
    );
  }
}