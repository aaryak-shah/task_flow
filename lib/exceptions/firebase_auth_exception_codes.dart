import 'package:firebase_auth/firebase_auth.dart';

String getMessageFromErrorCode(FirebaseAuthException error) {
  switch (error.code) {
    case "account-exists-with-different-credential":
    case "email-already-in-use":
      return "Another user already exists with that email. Try logging in instead.";
    case "wrong-password":
      return "Incorrect password ";
    case "user-not-found":
      return "No user found with this email.";
    case "user-disabled":
      return "User disabled.";
    case "operation-not-allowed":
      return "Server error, please try again later.";
    case "invalid-email":
      return "Email address is invalid.";
    default:
      return "Authentication failed, please try again later.";
  }
}
