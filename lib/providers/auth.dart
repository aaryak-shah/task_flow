import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  IdTokenResult _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  IdTokenResult get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) return _token;
    return null;
  }

  Future<String> get userName async {
    final prefs = await SharedPreferences.getInstance();
    notifyListeners();
    return prefs.getString('username');
  }

  Future<bool> get isAuth async {
    var res = await _auth.currentUser();
    notifyListeners();
    return res != null;
  }

  Future<String> get userId async {
    if (_userId == null) {
      var res = await _auth.currentUser();
      return res.uid;
    }
    return _userId;
  }

  Future<void> _authenticateWithEmail(
    String mode,
    String email,
    String password,
  ) async {
    try {
      AuthResult res;
      if (mode == 'signup') {
        res = (await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ));
      } else {
        res = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      }
      FirebaseUser user = res.user;
      _userId = user.uid;
      _token = await user.getIdToken();
      _expiryDate = _token.expirationTime;
    } catch (error) {
      throw error;
    }
    _autoLogout();
    notifyListeners();
  }

  Future<void> signupWithEmail(
    String userName,
    String email,
    String password,
  ) async {
    _authenticateWithEmail('signup', email, password);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('username', userName);
  }

  Future<void> loginWithEmail(
    String email,
    String password,
  ) async {
    _authenticateWithEmail('login', email, password);
  }

  Future<void> logout() async {
    _token = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    await _auth.signOut();
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
