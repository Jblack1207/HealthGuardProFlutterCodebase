import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Firebase Helpers/FirebaseAuth Helper.dart';
import '/pages/IoTHealthAppHomePage.dart';
import '/pages/IoTHealthAppLoginPage.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          return const IoTHealthAppHomePage();
        }

        return const IoTHealthAppLoginScreen();
      },
    );
  }
}