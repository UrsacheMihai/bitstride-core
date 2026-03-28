import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Handle data operations and service integration for the Auth Service.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: kIsWeb
        ? null
        : '1009649189286-0lbtu6mj0766nilqk2ev61oon85lpkg0.apps.googleusercontent.com',
  );

  User? get currentUser => _auth.currentUser;

  String? get uid => _auth.currentUser?.uid;

  bool get isAuthenticated => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}