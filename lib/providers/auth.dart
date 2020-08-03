import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    debugPrint('googleAuth called');
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
      _authResult = await _firebaseAuth.signInWithCredential(_credential);
      _user = _authResult.user;
      // assert(!_user.isAnonymous);
      // assert(await _user.getIdToken() != null);
      _currentUser = await _firebaseAuth.currentUser();
      // assert(_user.uid == _currentUser.uid);
      _token = await _currentUser.getIdToken();
      _expiryDate = _token.expirationTime;
      _userId = _currentUser.uid;
      _photoUrl = _currentUser.photoUrl;
    } catch (error) {
      print(error);
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
    String name,
    String mode,
    String email,
    String password,
  ) async {
    _isGuestUser = false;
    try {
      AuthResult res;
      if (mode == 'signup') {
        res = (await _auth.createUserWithEmailAndPassword(
          //firebase package method
          email: email,
          password: password,
        ));
      } else {
        res = await _auth.signInWithEmailAndPassword(
            //firebase package method
            email: email,
            password: password);
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
  }

  //method to sign up user with email
  Future<void> signupWithEmail(
    String userName,
    String email,
    String password,
  ) async {
    _authenticateWithEmail(userName, 'signup', email, password);
  }

  //method to sign in user with email
  Future<void> loginWithEmail(
    String email,
    String password,
  ) async {
    _authenticateWithEmail('', 'login', email, password);
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
    await _auth.signOut();
    bool isGoogleSignIn = await _googleSignIn.isSignedIn();
    if (isGoogleSignIn) {
      _googleSignIn.signOut();
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

// class GoogleAuth with ChangeNotifier {
//   bool isUsed = false;

//   FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: [
//       'email',
//       'https://www.googleapis.com/auth/userinfo.profile',
//     ],
//   );
//   GoogleSignInAccount _googleUser;
//   GoogleSignInAuthentication _googleAuthentication;
//   AuthCredential _credential;
//   AuthResult _authResult;
//   FirebaseUser _user;
//   FirebaseUser _currentUser;

//   IdTokenResult _token;
//   DateTime _expiryDate;
//   String _userId;
//   Timer _authTimer;

//   Future<void> googleAuth() async {
//     debugPrint('googleAuth called');
//     try {
//       _googleUser = await _googleSignIn.signIn();
//       _googleAuthentication = await _googleUser.authentication;
//       _credential = GoogleAuthProvider.getCredential(
//         idToken: _googleAuthentication.idToken,
//         accessToken: _googleAuthentication.accessToken,
//       );
//       _authResult = await _firebaseAuth.signInWithCredential(_credential);
//       _user = _authResult.user;
//       assert(!_user.isAnonymous);
//       assert(await _user.getIdToken() != null);
//       _currentUser = await _firebaseAuth.currentUser();
//       assert(_user.uid == _currentUser.uid);

//       _token = await _currentUser.getIdToken();
//       _expiryDate = _token.expirationTime;
//       _userId = _currentUser.uid;
//     } catch (error) {
//       print(error);
//     }
//   }
// }
