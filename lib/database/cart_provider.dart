import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  void refreshCheckOut() {
    notifyListeners();
  }
}
