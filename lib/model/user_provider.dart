import 'package:pricecompare/components/firebase_auth.dart';
import 'package:pricecompare/model/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  User? user;
  void getdata() {
    user = AuthService().checkUser(null);
    notifyListeners();
  }
}
