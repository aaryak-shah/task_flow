import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/exceptions/http_exception.dart';
import 'package:task_flow/providers/auth.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;
  Map<String, String> _authData = {
    'name': '',
    'email': '',
    'password': '',
  };

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Something went wrong!'),
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
      await Provider.of<Auth>(context, listen: false)
          .signup(_authData['name'] ,_authData['email'], _authData['password']);
      Navigator.of(context).pop();
    } on HttpException catch (error) {
      var errorMessage = 'Authentication error';
      if (error.message.contains('EMAIL_EXISTS')) {
        errorMessage = 'That email address is already in use';
      } else if (error.message.contains('INVALID_EMAIL')) {
        errorMessage = 'This email address is invalid';
      } else if (error.message.contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak';
      } else if (error.message.contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email address';
      } else if (error.message.contains('INVALID_PASSWORD')) {
        errorMessage = 'This password is invalid';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not sign you up, try again later.';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final authProvider = Provider.of<Auth>(context, listen: false);

    return Container(
      height: 360,
      constraints: BoxConstraints(minHeight: 360),
      width: deviceSize.width * 0.85,
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                autofocus: true,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  _emailFocusNode.requestFocus();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter a name';
                  }
                },
                onSaved: (value) {
                  _authData['name'] = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'E-Mail'),
                keyboardType: TextInputType.emailAddress,
                focusNode: _emailFocusNode,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  _passwordFocusNode.requestFocus();
                },
                validator: (value) {
                  if (value.isEmpty || !value.contains('@')) {
                    return 'Invalid email!';
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
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  _confirmPasswordFocusNode.requestFocus();
                },
                controller: _passwordController,
                validator: (value) {
                  if (value.isEmpty || value.length < 5) {
                    return 'Password is too short!';
                  }
                },
                onSaved: (value) {
                  _authData['password'] = value;
                },
              ),
              TextFormField(
                  focusNode: _confirmPasswordFocusNode,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match!';
                    }
                  }),
              SizedBox(
                height: 20,
              ),
              if (_isLoading)
                CircularProgressIndicator()
              else
                RaisedButton(
                  child: Text('SIGN UP'),
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
