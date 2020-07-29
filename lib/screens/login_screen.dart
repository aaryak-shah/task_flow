import 'package:flutter/material.dart';
import 'package:task_flow/screens/tabs_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Spacer(),
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
                  ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  onPressed: () {},
                  color: Colors.white,
                  textColor: Colors.black,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/google_logo.png',
                          scale: 14,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          'Sign In with Google',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(TabsScreen.routeName, arguments: 0);
                  },
                  child: Text(
                    'Continue without signing in',
                    style: TextStyle(
                      color: Colors.grey,
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
