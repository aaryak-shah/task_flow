import 'package:flutter/material.dart';

Widget showAppBar(BuildContext context) {
  // AppBar widget to be shown on pages
  return AppBar(
    centerTitle: true,
    elevation: 0.0,
    backgroundColor: Theme.of(context).primaryColor,
    title: RichText(
      text: TextSpan(children: <TextSpan>[
        TextSpan(
          text: 'TASK',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w300,
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
        ),
        TextSpan(
          text: 'FLOW',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            color: Theme.of(context).accentColor,
          ),
        ),
      ]),
    ),
  );
}
