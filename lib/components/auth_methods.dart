import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //signup
  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
    required Uint8List image,
  }) async {
    String result = "some error occured";
    try {
      if (name.isNotEmpty && password.isNotEmpty) {
        //register
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        String photourl = await StorageMethods()
            .uploadImageStorage('profilepics', image, false);

        //add college to database
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'uid': credential.user!.uid,
          'img': photourl,
        });
        result = "success";
      }
    } catch (err) {
      result = err.toString();
    }
    return result;
  }

  //login user
  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "some error occured";

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      } else {
        res = "Please enter all fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> bookmark({
    required String url,
    required String store,
    required String title,
    required String urlImage,
    required double price,
  }) async {
    String result = "some error occured";
    try {
      if (url.isNotEmpty && store.isNotEmpty) {
        await _firestore
            .collection('bookmarks')
            .doc(_auth.currentUser!.uid)
            .set(
          {
            'bookmarks': FieldValue.arrayUnion([
              {
                'url': url,
                'title': title,
                'store': store,
                'uid': _auth.currentUser!.uid,
                'urlImage': urlImage,
                'price': price,
              }
            ]),
          },
          SetOptions(merge: true),
        );

        result = "success";
      }
    } catch (err) {
      result = err.toString();
    }
    return result;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
