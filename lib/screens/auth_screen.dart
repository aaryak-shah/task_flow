import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/exceptions/http_exception.dart';
import 'package:task_flow/providers/auth_service.dart';
import 'package:task_flow/widgets/sign_in_form.dart';
import 'package:task_flow/widgets/sign_up_form.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isSigningIn = false; //bool flag to switch between sign in and sign up
  void _showFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Spacer(),
          //auth screen title...
          Text(
            'Welcome to'.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
              fontSize: 18,
              fontFamily: 'Montserrat',
            ),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: new TextSpan(
              children: <TextSpan>[
                new TextSpan(
                  text: 'TASK',
                  style: TextStyle(
                      fontSize: 45,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).textTheme.bodyText1.color),
                ),
                new TextSpan(
                  text: 'FLOW',
                  style: TextStyle(
                    fontSize: 45,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          //auth functionality...
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //Sign in with google button
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: RaisedButton(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  onPressed: () async {
                    try {
                      await Provider.of<AuthService>(context, listen: false)
                          .signInWithGoogle();
                    } on PlatformException catch (error) {
                      var errorMessage = 'Authentication error';
                      if (error.message.contains('sign_in_canceled') ||
                          error.message.contains('sign_in_failed')) {
                        errorMessage = 'Sign in failed, try again later';
                      } else if (error.message.contains('network_error')) {
                        errorMessage = 'Sign in failed due to network issue';
                      }
                      _showErrorDialog(
                          context, "Something went wrong", errorMessage);
                    } catch (error) {
                      // Navigator.of(context).pop();
                      const errorMessage =
                          'Could not sign you in, please try again later.';
                      _showErrorDialog(
                          context, "Something went wrong", errorMessage);
                    }
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
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
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
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //Skip authentication button
              GestureDetector(
                onTap: () async {
                  await Provider.of<AuthService>(context, listen: false)
                      .setGuestValue(true);
                },
                child: Text(
                  'Use this app as a guest',
                  style: TextStyle(
                    color: Theme.of(context).unselectedWidgetColor,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 80,
          )
        ],
      ),
    );
  }
}
