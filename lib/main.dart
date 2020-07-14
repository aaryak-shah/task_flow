import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/tabs_screen.dart';
import 'providers/tasks.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Tasks(),
      child: MaterialApp(
        title: 'Task Flow',
        theme: ThemeData(
          primaryColor: Color(0xFF121212),
          accentColor: Colors.lightGreenAccent,
          appBarTheme: AppBarTheme(
            textTheme: TextTheme(
              headline6: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 20
              ),
              overline: TextStyle(
                fontFamily: 'Montserrat'
              )
            )
          ),
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
      ),
    );
  }
}