import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  /// Changed to idTokenChanges as it updates depending on more cases.
  Stream<User?> get authStateChanges => _firebaseAuth.idTokenChanges();

  // ignore: avoid_positional_boolean_parameters
  Future<void> setGuestValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isGuestUser', value);
  }

  Future<bool> get isGuest async {
    final prefs = await SharedPreferences.getInstance();
    final bool isGuestUser = prefs.getBool('isGuestUser') ?? false;
    notifyListeners();
    return isGuestUser;
  }

  String? get displayName => FirebaseAuth.instance.currentUser?.displayName;
  String? get photoUrl => FirebaseAuth.instance.currentUser?.photoURL;

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await setGuestValue(true);
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    debugPrint("sign in with google");
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<String> emailSignIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        await setGuestValue(false);
        return "Signed in";
      } else {
        await user?.sendEmailVerification();
        return "not verified";
      }
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<String> emailSignUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
      user?.updateProfile(displayName: name);
      return "Signed up";
    } on FirebaseAuthException {
      rethrow;
    }
  }

  bool get isAuth => FirebaseAuth.instance.currentUser != null;

  bool get isGoogleUser =>
      FirebaseAuth.instance.currentUser?.providerData[0].providerId ==
      "google.com";

  Stream<GoogleSignInAccount?> get googleUserStream =>
      GoogleSignIn().onCurrentUserChanged;

  String? get userName {
    final User? user = FirebaseAuth.instance.currentUser;
    return user != null ? user.displayName : 'Guest';
  }

  Future<void> updateName(String name) async {
    final User? user = FirebaseAuth.instance.currentUser;
    await user?.updateProfile(displayName: name);
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }
}
