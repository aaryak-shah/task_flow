import 'package:firebase_auth/firebase_auth.dart';

String getMessageFromErrorCode(FirebaseAuthException error) {
  switch (error.code) {
    case "account-exists-with-different-credential":
    case "email-already-in-use":
      return "Another user already exists with that email. Try logging in instead.";
      break;
    case "wrong-password":
      return "Incorrect password ";
      break;
    case "user-not-found":
      return "No user found with this email.";
      break;
    case "user-disabled":
      return "User disabled.";
      break;
    case "operation-not-allowed":
      return "Too many requests to log into this account.";
      break;
    case "operation-not-allowed":
      return "Server error, please try again later.";
      break;
    case "invalid-email":
      return "Email address is invalid.";
      break;
    default:
      return "Authentication failed, please try again later.";
      break;
  }
}
