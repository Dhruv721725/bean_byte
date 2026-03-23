import 'package:bean_byte/models/user_model.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  final UserModel user;
  const OrdersScreen({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: Center(child: Text("Orders Screen"))),
    );
  }
}
