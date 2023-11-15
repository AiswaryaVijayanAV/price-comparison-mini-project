import 'package:pricecompare/components/firebase_auth.dart';
import 'package:pricecompare/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/user.dart';
import '../screens/login.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          return user == null ? Login() : HomeScreen();
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
