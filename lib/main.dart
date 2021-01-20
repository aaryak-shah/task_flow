import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_flow/providers/auth_service.dart';
import 'package:task_flow/providers/project.dart';
import 'package:task_flow/providers/projects.dart';
import 'package:task_flow/providers/settings.dart';
import 'package:task_flow/providers/theme_switcher.dart';
import 'package:task_flow/screens/home_screen.dart';

import 'screens/auth_screen.dart';

import './providers/goals.dart';
import './providers/task.dart';
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
  bool isGuest = false;
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
        Provider<AuthService>(
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
  void initState() {
    Future.delayed(Duration.zero, () async {
      final prefs = await SharedPreferences.getInstance();
      print('isGuest is... $isGuest before assignment');
      isGuest = prefs.getBool('isGuest') ?? false;
      print('isGuest is... $isGuest after assignment');
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    print('isGuest is... $isGuest before comparision');
    if (firebaseUser == null && !(isGuest)) {
      return Consumer<ThemeModel>(
        builder: (context, themeModel, _) => MaterialApp(
          theme: themeModel.currentTheme,
          home: LoginScreen(),
        ),
      );
    }
    return HomeScreen();
  }
}
