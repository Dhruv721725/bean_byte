import 'package:bean_byte/database/supabase_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login(String email, String pass) async {
    try {
      UserCredential creds = await _auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      User? user = creds.user;
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<User?> register(String name, String email, String pass) async {
    try {
      UserCredential creds = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      User? user = creds.user;
      if (user != null) {
        _auth.currentUser!.updateDisplayName(name);
      }
      await SupabaseDb().createUser(user!.uid, name, email);
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<User?> google_SignIn() async {
    try {
      UserCredential user;
      if (kIsWeb) {
        user = await _auth.signInWithPopup(GoogleAuthProvider());
        return user.user;
      } else {
        GoogleSignInAccount? acc = await GoogleSignIn().signIn();
        GoogleSignInAuthentication? googleAuth = await acc?.authentication;
        final credentials = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        user = await _auth.signInWithCredential(credentials);
        return user.user;
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  User? getUser() => _auth.currentUser;

  void logout() {
    _auth.signOut();
  }
}
