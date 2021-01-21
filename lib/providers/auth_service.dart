import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_flow/exceptions/http_exception.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  /// Changed to idTokenChanges as it updates depending on more cases.
  Stream<User> get authStateChanges => _firebaseAuth.idTokenChanges();

  Future<void> setGuestValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isGuestUser', value);
  }

  String get displayName => FirebaseAuth.instance.currentUser.displayName;
  String get photoUrl => FirebaseAuth.instance.currentUser.photoURL;

  /// This won't pop routes so you could do something like
  /// Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  /// after you called this method if you want to pop all routes.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await setGuestValue(true);
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    print("sign in with google");
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  /// There are a lot of different ways on how you can do exception handling.
  /// This is to make it as easy as possible but a better way would be to
  /// use your own custom class that would take the exception and return better
  /// error messages. That way you can throw, return or whatever you prefer with that instead.
  Future<String> emailSignIn({String email, String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = FirebaseAuth.instance.currentUser;
      if (user.emailVerified) {
        await setGuestValue(false);
        return "Signed in";
      } else {
        // print("not verified");
        await user.sendEmailVerification();
        // return "pls verify";
        // throw HttpException("pls verify");
        return "not verified";
      }
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  /// There are a lot of different ways on how you can do exception handling.
  /// This is to make it as easy as possible but a better way would be to
  /// use your own custom class that would take the exception and return better
  /// error messages. That way you can throw, return or whatever you prefer with that instead.
  Future<String> emailSignUp({
    String name,
    String email,
    String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = FirebaseAuth.instance.currentUser;
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
      user.updateProfile(displayName: name);
      return "Signed up";
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<bool> get isGoogleUser async {
    return await GoogleSignIn().isSignedIn();
  }

  String get userName {
    User user = FirebaseAuth.instance.currentUser;
    return user != null ? user.displayName : 'Guest';
  }

  Future<void> updateName(String name) async {
    User user = FirebaseAuth.instance.currentUser;
    await user.updateProfile(displayName: name);
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }
}
