import 'package:bean_byte/themes/app_theme.dart';
import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  IconData icon;
  String label;
  bool isSelected;

  CategoryChip({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
  });
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor
            : (isDark ? AppTheme.fieldDark : Colors.white),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 12,
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface.withAlpha(100),
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }
}
