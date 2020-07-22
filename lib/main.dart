import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/screens/settings_screen.dart';

import './screens/tabs_screen.dart';
import './screens/current_task.dart';
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
    return ChangeNotifierProvider(
      create: (context) => Tasks(),
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
        home: TabsScreen(),
        routes: {
          SettingsScreen.routeName: (_) => SettingsScreen()
        },
        onGenerateRoute: (settings) {
          if (settings.name == CurrentTaskScreen.routeName) {
            final int index = settings.arguments;
            return MaterialPageRoute(builder: (context) {
              return CurrentTaskScreen(index: index);
            });
          }
        },
      ),
    );
  }
}
