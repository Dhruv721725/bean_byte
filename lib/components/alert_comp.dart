import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlertComp extends StatelessWidget {
  final String message;
  final String title;
  AlertComp({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          fontFamily: GoogleFonts.orbitron().fontFamily,
        ),
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
