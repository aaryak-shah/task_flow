import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Auth Provider
class Auth with ChangeNotifier {
  IdTokenResult _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //getter for token data, returns _token
  IdTokenResult get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) return _token;
    return null;
  }

  //getter for username from shared prefs
  Future<String> get userName async {
    final prefs = await SharedPreferences.getInstance();
    notifyListeners();
    return prefs.getString('username');
  }

  //getter for isAuth bool flag. Utilises currentUser() method to obtain data and refresh user's token simultaneously
  Future<bool> get isAuth async {
    var res = await _auth.currentUser();
    notifyListeners();
    return res != null;
  }

  //getter for userId. Also utilises currentUser()
  Future<String> get userId async {
    if (_userId == null) {
      var res = await _auth.currentUser();
      return res.uid;
    }
    return _userId;
  }

  //general method to authenticate (sign up + sign in) user using email + password
  //uses mode parameter to switch between sign in and sign up
  Future<void> _authenticateWithEmail(
    String mode,
    String email,
    String password,
  ) async {
    try {
      AuthResult res;
      if (mode == 'signup') {
        res = (await _auth.createUserWithEmailAndPassword( //firebase package method
          email: email,
          password: password,
        ));
      } else {
        res = await _auth.signInWithEmailAndPassword( //firebase package method
            email: email, password: password);
      }
      FirebaseUser user = res.user;
      _userId = user.uid;
      _token = await user.getIdToken(); //obtain user's token data
      _expiryDate = _token.expirationTime; //obtain token expiry date
    } catch (error) {
      throw error;
    }
    _autoLogout(); //autologout method called to start logout timer based on token expiry date
    notifyListeners();
  }

  //method to sign up user with email
  Future<void> signupWithEmail(
    String userName,
    String email,
    String password,
  ) async {
    _authenticateWithEmail('signup', email, password);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('username', userName);
  }

  //method to sign in user with email
  Future<void> loginWithEmail(
    String email,
    String password,
  ) async {
    _authenticateWithEmail('login', email, password);
  }

  //method to logout user
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

  //method to auto-logout user on token expiration (in case token is not refreshed)
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
