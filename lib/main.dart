import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iot_app_project/firebase_options.dart';
import 'Pages/IoTHealthAppLoginPage.dart';
import 'package:google_fonts/google_fonts.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  print("Firebase Connected");
  runApp(const IoTHealthApp());
}

class IoTHealthApp extends StatelessWidget {
  const IoTHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IoTHealthApp',
      theme: ThemeData(
        textTheme: GoogleFonts.openSansTextTheme(),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const IoTHealthAppLoginScreen(),
    );
  }
}
