import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/providers/auth.dart';

import 'screens/auth_screen.dart';
import './screens/current_goal_screen.dart';
import './screens/stats_screen.dart';
import './screens/settings_screen.dart';
import './screens/tabs_screen.dart';
import 'screens/current_task_screen.dart';

import './providers/goals.dart';
import './providers/task.dart';
import './providers/tasks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var path = await getApplicationDocumentsDirectory();
  // create the tasks.csv file if it doesn't exist
  File f = File('${path.path}/tasks.csv');
  if (!f.existsSync()) {
    f.writeAsStringSync('');
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isAuth = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (context) => Tasks(context), //passing context for calling Auth provider in Tasks
        ),
        ChangeNotifierProvider(
          create: (context) => Task(),
        ),
        ChangeNotifierProvider(
          create: (context) => Goals(context), //passing context for calling Auth provider in Goals
        )
      ],
      child: Consumer<Auth>(builder: (context, auth, _) {
        auth.isAuth.then((value) {
          setState(() {
            isAuth = value;
          });
        });
        return MaterialApp(
          title: 'Task Flow',
          theme: ThemeData(
            // dark theme
            brightness: Brightness.dark,
            primaryColor: Color(0xFF121212),
            errorColor: Colors.redAccent,
            accentColor: Colors.lightGreenAccent,
            appBarTheme: AppBarTheme(
              textTheme: TextTheme(
                headline6: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 20),
                overline: TextStyle(fontFamily: 'Montserrat'),
              ),
            ),
            textTheme: TextTheme(
              bodyText1: TextStyle(
                color: Colors.white,
              ),
              bodyText2: TextStyle(
                color: Colors.white38,
              ),
              headline6: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          // setting home screen as tasks screen
          home: isAuth ? TabsScreen(0) : LoginScreen(),
          routes: {
            SettingsScreen.routeName: (_) => SettingsScreen(),
            StatsScreen.routeName: (_) => StatsScreen(),
          },
          onGenerateRoute: (settings) {
            // passing arguments to routes
            if (settings.name == CurrentTaskScreen.routeName) {
              final int index = (settings.arguments as Map)['index'];
              final bool wasSuspended =
                  (settings.arguments as Map)['wasSuspended'];
              return MaterialPageRoute(builder: (context) {
                return CurrentTaskScreen(
                  index: index,
                  wasSuspended: wasSuspended,
                );
              });
            } else if (settings.name == CurrentGoalScreen.routeName) {
              final int index = settings.arguments;
              return MaterialPageRoute(builder: (context) {
                return CurrentGoalScreen(
                  index: index,
                );
              });
            } else if (settings.name == TabsScreen.routeName) {
              final int selected = settings.arguments;
              return MaterialPageRoute(builder: (context) {
                return TabsScreen(selected);
              });
            }
          },
        );
      }),
    );
  }
}
