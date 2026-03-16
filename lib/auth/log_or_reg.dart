import 'package:bean_byte/screens/login_screen.dart';
import 'package:bean_byte/screens/register_screen.dart';
import 'package:flutter/widgets.dart';

class LogOrReg extends StatefulWidget {
  @override
  State<LogOrReg> createState() => _LogOrRegState();
}

class _LogOrRegState extends State<LogOrReg> {
  bool isLogin = true;
  void toggle() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLogin) {
      return LoginScreen(onToggle: toggle);
    } else {
      return RegisterScreen(onToggle: toggle);
    }
  }
}
