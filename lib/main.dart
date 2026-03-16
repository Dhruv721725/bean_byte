import 'package:bean_byte/auth/auth_gate.dart';
import 'package:bean_byte/firebase_options.dart';
import 'package:bean_byte/themes/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://bkpbetagljvfztlsujge.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJrcGJldGFnbGp2Znp0bHN1amdlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI5ODc5MDcsImV4cCI6MjA4ODU2MzkwN30.FiKM2pvLpp44CTF_gi9-tBvxI3LMtiM0y0n-sm85c3E',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bean & Byte',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: AuthGate(),
    );
  }
}
