import 'package:pricecompare/model/user.dart' as model;
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  model.User? checkUser(User? user) {
    if (user == null) {
      return null;
    } else {
      return model.User(user.uid, user.email);
    }
  }

  Stream<model.User?>? get user {
    return _firebaseAuth.authStateChanges().map((checkUser));
  }

  Future<model.User?> signInWithEmailAndPassword(
      String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return checkUser(credential.user);
  }

  Future<model.User?> signUpWithEmailAndPassword(
      String email, String password) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return checkUser(credential.user);
  }

  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }
}
