import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../exceptions/firebase_auth_exception_codes.dart';
import '../models/project.dart';
import '../providers/auth_service.dart';
import '../providers/projects.dart';
import '../providers/tasks.dart';

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _showErrorDialog(String title, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }

  void _showForgotPasswordDialog() {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Forgot your password?"),
          content: Form(
            key: _formKey,
            child: Theme(
              data: Theme.of(context)
                  .copyWith(primaryColor: Theme.of(context).accentColor),
              child: TextFormField(
                controller: _emailController,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(val ?? "")) {
                    return "Enter a valid email address";
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Email",
                ),
                textInputAction: TextInputAction.done,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    await Provider.of<AuthService>(context, listen: false)
                        .forgotPassword(_emailController.text);
                    Navigator.of(context).pop();
                    _showErrorDialog(
                      "Password reset mail sent",
                      "We have just sent you a link to reset your password. Please check your spam folder too",
                      context,
                    );
                  } on FirebaseAuthException catch (error) {
                    Navigator.of(context).pop();
                    final String errorMessage = getMessageFromErrorCode(error);
                    _showErrorDialog(
                      "Something went wrong",
                      errorMessage,
                      context,
                    );
                  }
                }
              },
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      debugPrint(await Provider.of<AuthService>(context, listen: false).emailSignIn(
        email: _authData['email'] ?? "",
        password: _authData['password'] ?? "",
      ));

      final bool isVerified = context.read<User>().emailVerified;
      if (isVerified) {
        Provider.of<Tasks>(context, listen: false).pullFromFireBase();
        await Provider.of<Projects>(context, listen: false).pullFromFireBase();
        for (final Project project
            in Provider.of<Projects>(context, listen: false).projects) {
          await project.pullFromFireBase();
        }
        Navigator.of(context).pop();
      } else {
        _showErrorDialog(
          "Email not verified",
          "We have just sent you a verification email. Please verify your email before continuing",
          context,
        );
      }
    } on FirebaseAuthException catch (error) {
      final String errorMessage = getMessageFromErrorCode(error);
      _showErrorDialog(
        "Something went wrong",
        errorMessage,
        context,
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Container(
      height: 250,
      constraints: const BoxConstraints(minHeight: 250),
      width: deviceSize.width * 0.85,
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Theme(
                data: Theme.of(context)
                    .copyWith(primaryColor: Theme.of(context).accentColor),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) {
                    _passwordFocusNode.requestFocus();
                  },
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Invalid email';
                    }
                  },
                  onSaved: (value) {
                    _authData['email'] = value ?? "";
                  },
                ),
              ),
              Theme(
                data: Theme.of(context)
                    .copyWith(primaryColor: Theme.of(context).accentColor),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  focusNode: _passwordFocusNode,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a password';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value ?? "";
                  },
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                ),
                onPressed: _showForgotPasswordDialog,
                child: const Text("Forgot password?"),
              ),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    primary: Colors.white,
                    onPrimary: Colors.black,
                  ),
                  child: const Text('SIGN IN'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
