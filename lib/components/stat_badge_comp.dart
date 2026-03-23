import 'package:bean_byte/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class StatBadgeComp extends StatelessWidget{
  final String value;
  final String label;
  StatBadgeComp({
    super.key,
    required this.label,
    required this.value
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(100)
          ),
        )
      ],
    );
  }
}