import 'package:flutter/material.dart';

Widget showAppBar(BuildContext context) {
  return AppBar(
    centerTitle: true,
    elevation: 0.0,
    backgroundColor: Theme.of(context).primaryColor,
    title: RichText(
      text: new TextSpan(children: <TextSpan>[
        new TextSpan(
          text: 'TASK',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w300,
          ),
        ),
        new TextSpan(
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
