import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _username;
  String? _email;

  String? get username => _username;
  String? get email => _email;

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void clear() {
    _username = null;
    _email = null;
    notifyListeners();
  }
}
