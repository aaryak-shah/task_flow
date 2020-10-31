import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:task_flow/exceptions/http_exception.dart';

//Auth Provider
class Auth with ChangeNotifier {
  bool _isGuestUser = false;
  IdTokenResult _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );
  String _photoUrl = '';

  Future<void> googleAuth() async {
    _isGuestUser = false;
    GoogleSignInAccount _googleUser;
    GoogleSignInAuthentication _googleAuthentication;
    AuthCredential _credential;
    AuthResult _authResult;
    FirebaseUser _user;
    FirebaseUser _currentUser;
    try {
      _googleUser = await _googleSignIn.signIn();
      _googleAuthentication = await _googleUser.authentication;
      _credential = GoogleAuthProvider.getCredential(
        idToken: _googleAuthentication.idToken,
        accessToken: _googleAuthentication.accessToken,
      );
      _authResult = await _auth.signInWithCredential(_credential);
      _user = _authResult.user;
      _currentUser = await _auth.currentUser();
      _token = await _currentUser.getIdToken();
      _expiryDate = _token.expirationTime;
      _userId = _currentUser.uid;
      _photoUrl = _currentUser.photoUrl;
    } catch (error) {
      throw error;
    }
  }

  bool get isGuestUser {
    return _isGuestUser;
  }

  void setGuest() {
    _isGuestUser = true;
    notifyListeners();
  }

  //getter for token data, returns _token
  IdTokenResult get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) return _token;
    return null;
  }

  String get photoUrl {
    return _photoUrl;
  }

  //getter for username from shared prefs
  Future<String> get userName async {
    var user = await _auth.currentUser();
    notifyListeners();
    return user != null ? user.displayName : 'Guest';
  }

  Future<String> get email async {
    var user = await _auth.currentUser();
    notifyListeners();
    return user != null ? user.email : "";
  }

  Future<void> updateName(String name) async {
    var user = await _auth.currentUser();
    UserUpdateInfo userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = name;
    await user.updateProfile(userUpdateInfo);
    notifyListeners();
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      notifyListeners();
    } catch (error) {
      throw HttpException(error.code);
    }
  }
  //getter for isAuth bool flag. Utilises currentUser() method to obtain data and refresh user's token simultaneously
  Future<bool> get isAuth async {
    var user = await _auth.currentUser();
    if (user != null) {
      _token = await user.getIdToken();
      _expiryDate = _token.expirationTime;
      _photoUrl = user.photoUrl ?? '';
      _userId = user.uid;
    }
    notifyListeners();
    return user != null && user.isEmailVerified;
  }

  //getter for userId. Also utilises currentUser()
  Future<String> get userId async {
    if (_userId == null) {
      var res = await _auth.currentUser();
      return res.uid;
    }
    return _userId;
  }

  Future<bool> get isGoogleUser async {
    return await _googleSignIn.isSignedIn();
  }

  //general method to authenticate (sign up + sign in) user using email + password
  //uses mode parameter to switch between sign in and sign up
  Future<bool> _authenticateWithEmail(
    String name,
    String mode,
    String email,
    String password,
  ) async {
    _isGuestUser = false;
    AuthResult res;
    try {
      if (mode == 'signup') {
        res = (await _auth.createUserWithEmailAndPassword(
          //firebase package method
          email: email,
          password: password,
        ));
        await res.user.sendEmailVerification();
      } else {
        res = await _auth.signInWithEmailAndPassword(
            //firebase package method
            email: email,
            password: password);
        if (!res.user.isEmailVerified) {
          await res.user.sendEmailVerification();
        }
      }
      FirebaseUser user = res.user;
      _userId = user.uid;
      _token = await user.getIdToken(); //obtain user's token data
      _expiryDate = _token.expirationTime; //obtain token expiry date

      if (mode == 'signup') {
        UserUpdateInfo info = UserUpdateInfo();
        info.displayName = name;
        user.updateProfile(info);
      }
    } catch (error) {
      throw error;
    }

    _autoLogout(); //autologout method called to start logout timer based on token expiry date
    notifyListeners();
    return res.user.isEmailVerified;
  }

  //method to sign up user with email
  Future<void> signupWithEmail(
    String userName,
    String email,
    String password,
  ) async {
    await _authenticateWithEmail(userName, 'signup', email, password);
  }

  //method to sign in user with email
  Future<bool> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await _authenticateWithEmail('', 'login', email, password);
    } catch (error) {
      throw HttpException(error.code);
    }
  }

  //method to logout user
  Future<void> logout() async {
    _isGuestUser = true;
    _token = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    await FirebaseAuth.instance.signOut();
    bool isGoogleSignIn = await _googleSignIn.isSignedIn();
    if (isGoogleSignIn) {
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
    }
    _photoUrl = '';
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
