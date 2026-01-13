// lib/services/auth_service.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  AuthService() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((fb_auth.User? fbUser) async {
      if (fbUser != null) {
        await _fetchAndSetUser(fbUser.uid);
      } else {
        _currentUser = null;
        _isAuthenticated = false;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchAndSetUser(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists) {
        _currentUser = User.fromFirestore(doc);
        _isAuthenticated = true;
      } else {
        _currentUser = null;
        _isAuthenticated = true;
        if (kDebugMode) print('Warning: No Firestore document for user $uid');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Fetch User Error: $e');
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  // THIS IS THE MISSING METHOD CAUSING YOUR ERROR
  Future<fb_auth.User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final fb_auth.AuthCredential credential =
          fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fb_auth.UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final fb_auth.User? fbUser = userCredential.user;

      if (fbUser != null) {
        final doc = await _firestore.collection('users').doc(fbUser.uid).get();

        if (!doc.exists) {
          final newUser = User(
            id: fbUser.uid,
            name: fbUser.displayName ?? 'Google User',
            email: fbUser.email ?? '',
            matricNo: 'N/A',
            faculty: 'N/A',
            residentialCollege: 'N/A',
            points: 0,
            level: 1,
            rank: 'New Recycler',
            totalRecycled: 0.0,
            co2Saved: 0.0,
            badges: ['New Recruit'],
            joinDate: DateTime.now(),
          );

          await _firestore
              .collection('users')
              .doc(fbUser.uid)
              .set(newUser.toMap())
              .timeout(const Duration(seconds: 10));

          _currentUser = newUser;
        }
      }
      return fbUser;
    } catch (e) {
      if (kDebugMode) print('Google Sign-In Error: $e');
      return null;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user != null;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) print('Login Error: ${e.code}');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password,
      String matricNo, String faculty, String college) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        final newUser = User(
          id: uid,
          name: name,
          email: email,
          matricNo: matricNo,
          faculty: faculty,
          residentialCollege: college,
          points: 0,
          level: 1,
          rank: 'New Recycler',
          totalRecycled: 0.0,
          co2Saved: 0.0,
          badges: ['New Recruit'],
          joinDate: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(uid)
            .set(newUser.toMap())
            .timeout(const Duration(seconds: 10));

        _currentUser = newUser;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) print('Registration Error: ${e.code}');
      return false;
    } catch (e) {
      if (kDebugMode) print('Unexpected Error: $e');
      return false;
    }
  }

  void logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
