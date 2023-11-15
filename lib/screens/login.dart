// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:pricecompare/components/firebase_auth.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController email = TextEditingController();
    final TextEditingController password = TextEditingController();
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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
                await authService.signInWithEmailAndPassword(
                    email.text.trim(), password.text.trim());
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
              ),
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
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
