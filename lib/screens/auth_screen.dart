import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/exceptions/http_exception.dart';
import 'package:task_flow/providers/auth.dart';
import 'package:task_flow/providers/tasks.dart';
import 'package:task_flow/screens/tabs_screen.dart';
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
              text: new TextSpan(children: <TextSpan>[
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
              ]),
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
                        borderRadius: BorderRadius.circular(30)),
                    onPressed: () async {
                      try {
                        await Provider.of<Auth>(context, listen: false)
                            .googleAuth();
                        await Provider.of<Tasks>(context, listen: false).pullFromFireBase();
                      } on PlatformException catch (error) {
                        var errorMessage = 'Authentication error';
                        if (error.message.contains('sign_in_canceled') ||
                            error.message.contains('sign_in_failed')) {
                          errorMessage = 'Sign in failed, try again later';
                        } else if (error.message.contains('network_error')) {
                          errorMessage = 'Sign in failed due to network issue';
                        }
                        _showErrorDialog("Something went wrong", errorMessage);
                      } catch (error) {
                        Navigator.of(context).pop();
                        const errorMessage =
                            'Could not sign you in, please try again later.';
                        _showErrorDialog("Something went wrong", errorMessage);
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
            SizedBox(
              height: 10,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     //Sign up with email button
            //     RaisedButton(
            //       padding: EdgeInsets.symmetric(vertical: 8),
            //       shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(30)),
            //       onPressed: () {
            //         setState(() {
            //           isSigningIn = false;
            //         });
            //         _showFormDialog(context);
            //       },
            //       color: Colors.white,
            //       textColor: Colors.black,
            //       child: Container(
            //         width: MediaQuery.of(context).size.width * 0.4,
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: <Widget>[
            //             Icon(Icons.assignment_ind),
            //             SizedBox(
            //               width: 10,
            //             ),
            //             Text(
            //               'Sign Up',
            //               textAlign: TextAlign.center,
            //               style: TextStyle(
            //                 fontSize: 18,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // SizedBox(
            //   height: 10,
            // ),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     RawMaterialButton(
            //       onPressed: () {},
            //       elevation: 2.0,
            //       fillColor: Colors.white,
            //       child: Image.asset('assets/images/google_logo.png', scale: 15,),
            //       padding: EdgeInsets.all(3.0),
            //       shape: CircleBorder(),
            //     ),
            //     RawMaterialButton(
            //       onPressed: () {},
            //       elevation: 2.0,
            //       fillColor: Colors.white,
            //       child: Image.asset('assets/images/facebook_logo.png'),
            //       padding: EdgeInsets.all(3.0),
            //       shape: CircleBorder(),
            //     )
            //   ],
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //Skip authentication button
                GestureDetector(
                  onTap: () {
                    Provider.of<Auth>(context, listen: false).setGuest();
                    Navigator.of(context).pushReplacementNamed(
                        TabsScreen.routeName,
                        arguments: 0);
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
        ));
  }
}
