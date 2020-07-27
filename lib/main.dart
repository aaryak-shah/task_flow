import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import './screens/current_goal_screen.dart';
import './screens/stats_screen.dart';
import './screens/settings_screen.dart';
import './screens/tabs_screen.dart';
import './screens/current_task.dart';

import './providers/goals.dart';
import './providers/task.dart';
import './providers/tasks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var path = await getApplicationDocumentsDirectory();
  File f = File('${path.path}/tasks.csv');
  if (!f.existsSync()) {
    f.writeAsStringSync('');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Tasks(),
        ),
        ChangeNotifierProvider(
          create: (context) => Task(),
        ),
        ChangeNotifierProvider(
          create: (context) => Goals(),
        )
      ],
      child: MaterialApp(
        title: 'Task Flow',
        theme: ThemeData(
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
        home: TabsScreen(0),
        routes: {
          SettingsScreen.routeName: (_) => SettingsScreen(),
          StatsScreen.routeName: (_) => StatsScreen(),
        },
        onGenerateRoute: (settings) {
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
          }
        },
      ),
    );
  }
}
