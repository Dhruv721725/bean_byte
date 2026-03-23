import 'package:bean_byte/auth/log_or_reg.dart';
import 'package:bean_byte/screens/navigation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    return StreamBuilder(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: Lottie.asset("lotties/loader.json")),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          snapshot.hasError ? print(snapshot.error.toString()) : null;
          return LogOrReg();
        } else {
          return NavigationScreen();
        }
      },
    );
  }
}
