import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/exceptions/http_exception.dart';
import 'package:task_flow/providers/tasks.dart';

import '../widgets/sign_in_form.dart';
import '../widgets/sign_up_form.dart';
import '../providers/auth.dart';
import '../widgets/app_bar.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile-screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isAuthenticated = false;
  bool _usingGoogle = true;
  bool _isSyncing = false;
  bool isSigningIn = true;
  bool isEditingName = false;
  String userName = 'Guest';
  String photoUrl = '';
  String email = '';
  Auth provider;

  void _showFormDialog(BuildContext context) {
    showDialog(
      context: context,
      child: AlertDialog(
        //dialog window for authentication forms
        titlePadding: EdgeInsets.fromLTRB(20, 20, 0, 0),
        contentPadding: EdgeInsets.symmetric(horizontal: 5),
        title: Text(isSigningIn ? 'Sign In' : 'Sign Up'),
        actionsPadding: EdgeInsets.only(right: 15, bottom: 5),
        content: isSigningIn ? SignInForm() : SignUpForm(),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              //auth mode switcher
              isSigningIn = !isSigningIn;
              Navigator.of(context).pop();
              _showFormDialog(context);
            },
            child: Text(
              isSigningIn ? 'Sign Up instead' : 'Sign In instead',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

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

  Future<void> _showUpdatePasswordDialog() async {
    var email = await Provider.of<Auth>(context, listen: false).email;
    try {
      await Provider.of<Auth>(context, listen: false).forgotPassword(email);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Password update email sent"),
            content: Text("Login using your new password"),
            actions: [
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              )
            ],
          );
        },
      );
      Provider.of<Auth>(context, listen: false).logout();
    } on HttpException catch (error) {
      Navigator.of(context).pop();
      var errorMessage = 'An error occurred';
      if (error.message.contains('ERROR_TOO_MANY_REQUESTS')) {
        errorMessage = 'Please try again later';
      }
      _showErrorDialog("Something went wrong", errorMessage);
    } catch (error) {
      Navigator.of(context).pop();
      const errorMessage = 'Could not change password.';
      _showErrorDialog("Something went wrong", errorMessage);
    }
  }

  @override
  void didChangeDependencies() {
    provider = Provider.of<Auth>(context);
    setState(() {
      photoUrl = provider.photoUrl;
    });
    provider.isAuth.then((value) {
      setState(() {
        _isAuthenticated = value;
      });
    });
    provider.isGoogleUser.then((value) {
      setState(() {
        _usingGoogle = value;
      });
    });
    provider.userName.then((value) {
      if (value != null) userName = value;
    });
    provider.email.then((value) {
      setState(() {
        email = value;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar(context),
      backgroundColor: Theme.of(context).primaryColor,
      body: _isAuthenticated
          ? Column(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: photoUrl == ''
                        ? AssetImage(
                            'assets/images/default_pfp.png',
                          )
                        : NetworkImage(photoUrl),
                  ),
                  title: Theme(
                    data: Theme.of(context)
                        .copyWith(primaryColor: Theme.of(context).accentColor),
                    child: TextFormField(
                      autofocus: !_usingGoogle,
                      initialValue: userName,
                      validator: (val) {
                        if (val.trim().isEmpty) {
                          return "Enter a name";
                        }
                      },
                      textInputAction: TextInputAction.done,
                      readOnly: !isEditingName,
                      onFieldSubmitted: (name) async {
                        await Provider.of<Auth>(context, listen: false)
                            .updateName(name);
                        setState(() {
                          isEditingName = false;
                        });
                      },
                    ),
                  ),
                  subtitle: Text(email),
                  trailing: !_usingGoogle
                      ? IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              isEditingName = true;
                            });
                          },
                        )
                      : null,
                ),
                SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      photoUrl = '';
                    });
                    provider.logout();
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.exit_to_app,
                    ),
                    title: Text('Sign Out'),
                  ),
                ),
                if (!_usingGoogle)
                  InkWell(
                    onTap: _showUpdatePasswordDialog,
                    child: ListTile(
                      leading: Icon(Icons.lock_outline),
                      title: Text('Change Password'),
                    ),
                  ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isSyncing = true;
                    });
                    Provider.of<Tasks>(context, listen: false)
                        .syncWithFirebase()
                        .then((_) {
                      setState(() {
                        _isSyncing = false;
                      });
                    });
                  },
                  child: ListTile(
                    leading: _isSyncing
                        ? CircularProgressIndicator(
                            strokeWidth: 1,
                          )
                        : Icon(Icons.sync),
                    title: Text('Sync My Data'),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //Sign in with google button
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: RaisedButton(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        onPressed: () {
                          Provider.of<Auth>(context, listen: false)
                              .googleAuth();
                        },
                        color: Color(0xDEFFFFFF),
                        textColor: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              "assets/images/google_logo.png",
                              scale: 20,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Sign In With Google',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //Sign in with email button
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: RaisedButton(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        onPressed: () {
                          setState(() {
                            isSigningIn = true;
                          });
                          _showFormDialog(context);
                        },
                        color: Color(0xDEFFFFFF),
                        textColor: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.email),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Continue With Email',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
