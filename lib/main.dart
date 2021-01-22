import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/providers/auth_service.dart';
import 'package:task_flow/providers/project.dart';
import 'package:task_flow/providers/projects.dart';
import 'package:task_flow/providers/settings.dart';
import 'package:task_flow/providers/theme_switcher.dart';
import 'package:task_flow/screens/home_screen.dart';

import 'screens/auth_screen.dart';

import './providers/goals.dart';
import './providers/tasks.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var path = await getApplicationDocumentsDirectory();
  // create the tasks.csv file if it doesn't exist
  File f = File('${path.path}/tasks.csv');
  if (!f.existsSync()) {
    f.writeAsStringSync('');
  }

  File f2 = File('${path.path}/projects.csv');
  if (!f2.existsSync()) {
    f2.writeAsStringSync('');
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
  // bool isGuest = false;
  bool isInit = true;
  // ThemeData theme = ThemeData(
  //   brightness: Brightness.dark,
  //   primaryColor: Color(0xFF121212),
  //   accentColor: Colors.lightGreenAccent,
  // );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<AuthService>().authStateChanges,
        ),
        // ChangeNotifierProvider(
        //   create: (context) => Auth(),
        // ),
        ChangeNotifierProvider(
          create: (context) => Tasks(
              context), //passing context for calling Auth provider in Tasks
        ),
        ChangeNotifierProvider(
          create: (context) => Goals(
              context), //passing context for calling Auth provider in Goals
        ),
        ChangeNotifierProvider(
          create: (context) => Projects(
            context,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => Project(
            context,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => Settings(),
        )
      ],
      child: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool isGuest = false;

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    print('isGuest is... $isGuest before comparision');
    return FutureBuilder<bool>(
      future: Provider.of<AuthService>(context).isGuest,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Consumer<ThemeModel>(
            builder: (context, themeModel, _) => MaterialApp(
              theme: themeModel.currentTheme,
              home: LoginScreen(),
            ),
          );
        } else {
          print('isGuest is... ${snapshot.data} after comparision');

          if ((snapshot.data) ||
              ((firebaseUser != null) && (firebaseUser.emailVerified))) {
            return HomeScreen();
          } else {
            return Consumer<ThemeModel>(
              builder: (context, themeModel, _) => MaterialApp(
                theme: themeModel.currentTheme,
                home: LoginScreen(),
              ),
            );
          }
        }
      },
    );
  }
}
