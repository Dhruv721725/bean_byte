import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonComp extends StatelessWidget {
  String label;
  Function() onTap;

  ButtonComp({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        width: double.maxFinite,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepOrangeAccent, Colors.orangeAccent],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: GoogleFonts.orbitron().fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
    );
  }
}
