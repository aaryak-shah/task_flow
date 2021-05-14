import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_service.dart';
import '../widgets/sign_in_form.dart';
import '../widgets/sign_up_form.dart';

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
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
        contentPadding: const EdgeInsets.symmetric(horizontal: 5),
        title: Text(isSigningIn ? 'Sign In' : 'Sign Up'),
        actionsPadding: const EdgeInsets.only(right: 15, bottom: 5),
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
              style: const TextStyle(
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
              child: const Text('OK'),
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
          const Spacer(),
          //auth screen title...
          Text(
            'Welcome to'.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1!.color,
              fontSize: 18,
              fontFamily: 'Montserrat',
            ),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'TASK',
                  style: TextStyle(
                    fontSize: 45,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).textTheme.bodyText1!.color,
                  ),
                ),
                TextSpan(
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
          const Spacer(),
          //auth functionality...
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //Sign in with google button
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    primary: const Color(0xDEFFFFFF),
                    onPrimary: Colors.black,
                  ),
                  onPressed: () async {
                    try {
                      await Provider.of<AuthService>(context, listen: false)
                          .signInWithGoogle();
                    } on PlatformException catch (error) {
                      var errorMessage = 'Authentication error';
                      final String msg = error.message ?? "";
                      if ((msg.contains('sign_in_canceled')) ||
                          msg.contains('sign_in_failed')) {
                        errorMessage = 'Sign in failed, try again later';
                      } else if (msg.contains('network_error')) {
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        "assets/images/google_logo.png",
                        scale: 20,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
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
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //Sign in with email button
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    primary: const Color(0xDEFFFFFF),
                    onPrimary: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      isSigningIn = true;
                    });
                    _showFormDialog(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
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
          const SizedBox(
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
          const SizedBox(
            height: 80,
          )
        ],
      ),
    );
  }
}