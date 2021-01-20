import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/providers/auth.dart';
import 'package:task_flow/providers/auth_service.dart';
import 'package:task_flow/providers/project.dart';
import 'package:task_flow/providers/projects.dart';
import 'package:task_flow/providers/settings.dart';
import 'package:task_flow/providers/theme_switcher.dart';
import 'package:task_flow/screens/clients_screen.dart';
import 'package:task_flow/screens/current_project_screen.dart';
import 'package:task_flow/screens/profile_screen.dart';

import 'screens/auth_screen.dart';
import './screens/current_goal_screen.dart';
import './screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import './screens/tabs_screen.dart';
import 'screens/current_task_screen.dart';

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
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (context) => Tasks(
              context), //passing context for calling Auth provider in Tasks
        ),
        ChangeNotifierProvider(
          create: (context) => Task(),
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
      child: Consumer<Auth>(builder: (context, auth, _) {
        auth.isAuth.then(
          (value) async {
            setState(() {
              isAuth = value;
              if (!value) isInit = true;
            });
            if (value && isInit) {
              isInit = false;
              Provider.of<Tasks>(context, listen: false).pullFromFireBase();
              await Provider.of<Projects>(context, listen: false)
                  .pullFromFireBase();
              for (Project project
                  in Provider.of<Projects>(context, listen: false).projects) {
                project.pullFromFireBase();
              }
              setState(() {
                isInit = false;
              });
            }
          },
        );
        auth.isGuestUser.then((value) {
          setState(() {
            isGuest = value;
          });
        });
        // theme = Provider.of<ThemeModel>(context, listen: false).currentTheme;

        return Consumer<ThemeModel>(
          builder: (context, themeModel, _) => MaterialApp(
            title: 'Task Flow',
            theme: themeModel.currentTheme,
            // setting home screen as tasks screen
            home: (isAuth || isGuest) ? TabsScreen(0) : LoginScreen(),
            routes: {
              SettingsScreen.routeName: (_) => SettingsScreen(),
              StatsScreen.routeName: (_) => StatsScreen(),
              ProfileScreen.routeName: (_) => ProfileScreen(),
              ClientsScreen.routeName: (_) => ClientsScreen(),
            },
            onGenerateRoute: (settings) {
              // passing arguments to routes
              if (settings.name == CurrentTaskScreen.routeName) {
                final int index = (settings.arguments as Map)['index'];
                final bool wasSuspended =
                    (settings.arguments as Map)['wasSuspended'];
                final String superProjectName =
                    (settings.arguments as Map)['superProjectName'];
                final String superProjectId =
                    (settings.arguments as Map)['superProjectId'];
                return MaterialPageRoute(builder: (context) {
                  return CurrentTaskScreen(
                    index: index,
                    wasSuspended: wasSuspended,
                    superProjectName: superProjectName,
                    superProjectId: superProjectId,
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
              } else if (settings.name == CurrentProjectScreen.routeName) {
                final String id = (settings.arguments as Map)['projectId'];
                final int index = (settings.arguments as Map)['index'];
                final bool isFromClients =
                    (settings.arguments as Map)['isFromClients'];
                return MaterialPageRoute(builder: (context) {
                  return CurrentProjectScreen(
                    projectId: id,
                    index: index,
                    isFromClients: isFromClients,
                  );
                });
              }
            },
          ),
        );
      }),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    if (firebaseUser == null) {
      return LoginScreen();
    }
    return Consumer<ThemeModel>(
      builder: (context, themeModel, _) => MaterialApp(
        title: 'Task Flow',
        theme: themeModel.currentTheme,
        // setting home screen as tasks screen
        home: TabsScreen(0),
        routes: {
          SettingsScreen.routeName: (_) => SettingsScreen(),
          StatsScreen.routeName: (_) => StatsScreen(),
          ProfileScreen.routeName: (_) => ProfileScreen(),
          ClientsScreen.routeName: (_) => ClientsScreen(),
        },
        onGenerateRoute: (settings) {
          // passing arguments to routes
          if (settings.name == CurrentTaskScreen.routeName) {
            final int index = (settings.arguments as Map)['index'];
            final bool wasSuspended =
                (settings.arguments as Map)['wasSuspended'];
            final String superProjectName =
                (settings.arguments as Map)['superProjectName'];
            final String superProjectId =
                (settings.arguments as Map)['superProjectId'];
            return MaterialPageRoute(builder: (context) {
              return CurrentTaskScreen(
                index: index,
                wasSuspended: wasSuspended,
                superProjectName: superProjectName,
                superProjectId: superProjectId,
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
          } else if (settings.name == CurrentProjectScreen.routeName) {
            final String id = (settings.arguments as Map)['projectId'];
            final int index = (settings.arguments as Map)['index'];
            final bool isFromClients =
                (settings.arguments as Map)['isFromClients'];
            return MaterialPageRoute(builder: (context) {
              return CurrentProjectScreen(
                projectId: id,
                index: index,
                isFromClients: isFromClients,
              );
            });
          }
        },
      ),
    );
  }
}
