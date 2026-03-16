import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextFieldComp extends StatefulWidget {
  IconData prefixIcon;
  String labelText;
  String hintText;
  TextEditingController controller;
  bool isPassword;

  TextFieldComp({
    required this.prefixIcon,
    required this.labelText,
    required this.hintText,
    required this.controller,
    required this.isPassword,
  });

  @override
  State<TextFieldComp> createState() => _TextFieldCompState();
}

class _TextFieldCompState extends State<TextFieldComp> {
  late bool obscureText = widget.isPassword;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: obscureText,

      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,

        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
        ),

        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(),

        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),

        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),

        prefixIcon: Icon(
          widget.prefixIcon,
          color: Theme.of(context).primaryColor,
        ),

        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}
