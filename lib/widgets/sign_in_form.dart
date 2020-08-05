import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/exceptions/http_exception.dart';
import 'package:task_flow/providers/auth.dart';

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            )
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      bool isVerified = await Provider.of<Auth>(context, listen: false)
          .loginWithEmail(_authData['email'], _authData['password']);
      if (isVerified) {
        Navigator.of(context).pop();
      } else {
        _showErrorDialog("Email not verified",
            "We have just sent you a verification email. Please verify your email before continuing");
      }
    } on HttpException catch (error) {
      print(error);
      var errorMessage = 'Authentication error';
      if (error.message.contains('ERROR_INVALID_EMAIL')) {
        errorMessage = 'This email address is invalid';
      } else if (error.message.contains('ERROR_USER_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email address';
      } else if (error.message.contains('ERROR_WRONG_PASSWORD')) {
        errorMessage = 'This password is invalid';
      } else if (error.message.contains('ERROR_TOO_MANY_REQUESTS')) {
        errorMessage = 'Please try again later';
      }
      _showErrorDialog("Something went wrong", errorMessage);
    } catch (error) {
      const errorMessage = 'Could not sign you in, please try again later.';
      _showErrorDialog("Something went wrong", errorMessage);
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
      height: 220,
      constraints: BoxConstraints(minHeight: 220),
      width: deviceSize.width * 0.85,
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'E-Mail'),
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  _passwordFocusNode.requestFocus();
                },
                validator: (value) {
                  if (value.isEmpty || !value.contains('@')) {
                    return 'Invalid email';
                  }
                },
                onSaved: (value) {
                  _authData['email'] = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                focusNode: _passwordFocusNode,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                controller: _passwordController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter a password';
                  }
                },
                onSaved: (value) {
                  _authData['password'] = value;
                },
              ),
              SizedBox(
                height: 20,
              ),
              if (_isLoading)
                CircularProgressIndicator()
              else
                RaisedButton(
                  child: Text('SIGN IN'),
                  onPressed: _submit,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                  color: Colors.white,
                  textColor: Colors.black,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
