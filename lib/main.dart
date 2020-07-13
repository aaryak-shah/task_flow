import 'package:flutter/material.dart';

import './screens/tabs_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Flow',
      theme: ThemeData(
        primaryColor: Color(0xFF121212),
        accentColor: Colors.lightGreenAccent,
        textTheme: TextTheme(
          bodyText1: TextStyle(
            color: Colors.white,
          ),
          headline6: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      home: TabsScreen(),
      routes: {
        
      },
    );
  }
}