// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:pricecompare/components/firebase_auth.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController email = TextEditingController();
    final TextEditingController password = TextEditingController();
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(labelText: 'Email Id'),
            ),
            TextField(
              controller: password,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () async {
                await authService.signUpWithEmailAndPassword(
                  email.text.trim(),
                  password.text.trim(),
                );
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
              ),
              child: Text('Register'),
            )
          ],
        ),
      ),
    );
  }
}
