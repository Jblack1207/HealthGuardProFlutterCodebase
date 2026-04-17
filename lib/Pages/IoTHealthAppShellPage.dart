import 'package:flutter/material.dart';
import 'package:iot_app_project/Pages/IoTHealthAppHRPage.dart';
import 'package:iot_app_project/Pages/IoTHealthAppHomePage.dart';

import '../Helpers/NavBar Helper.dart';
import 'IoTHealthAppCamPage.dart';

class IoTHealthAppShellPage extends StatefulWidget {
  const IoTHealthAppShellPage({super.key});

  @override
  State<IoTHealthAppShellPage> createState() =>
      IoTHealthAppShellPageState();
}

class IoTHealthAppShellPageState
    extends State<IoTHealthAppShellPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    IoTHealthAppHomePage(),
    Iothealthapphrpage(),
    SizedBox(),
    IoTHealthAppCamPage(),
    Placeholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xff1F1F1F),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: _pages[_selectedIndex],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: const EdgeInsets.only(top: 34, right: 25, left: 25, bottom: 6),
                child: BcbBottomNav(
                  selectedIndex: _selectedIndex,
                  onTap: (index) {
                    print('Tapped index: $index');
                    if (index == 2) {
                      return;
                    }

                    setState(() {
                      _selectedIndex = index;
                      print('New selectedIndex: $_selectedIndex');
                    });
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
