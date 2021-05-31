import 'dart:isolate';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/providers/tasks.dart';
import '../providers/theme_switcher.dart';
import 'clients_screen.dart';
import 'current_goal_screen.dart';
import 'current_project_screen.dart';
import 'current_task_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'tabs_screen.dart';

class HomeScreen extends StatefulWidget {
  final ReceivePort appReceivePort;
  const HomeScreen(this.appReceivePort);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInit = true;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<CurrentTaskScreenState> taskKey =
      GlobalKey<CurrentTaskScreenState>();
  @override
  void didChangeDependencies() {
    if (_isInit) {
      widget.appReceivePort.listen((message) async {
        if (message == "pullFromFireBase") {
          await Provider.of<Tasks>(context, listen: false).pullFromFireBase();
          taskKey.currentState?.popper();
        }
      });
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    widget.appReceivePort.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<User?, ThemeModel>(
      builder: (context, user, themeModel, _) => MaterialApp(
        title: 'Task Flow',
        theme: themeModel.currentTheme,
        navigatorKey: navigatorKey,
        // setting home screen as tasks screen
        home: const TabsScreen(0),
        routes: {
          SettingsScreen.routeName: (_) => SettingsScreen(),
          StatsScreen.routeName: (_) => StatsScreen(),
          ProfileScreen.routeName: (_) => ProfileScreen(user),
          ClientsScreen.routeName: (_) => ClientsScreen(),
        },
        onGenerateRoute: (settings) {
          // passing arguments to routes
          if (settings.name == CurrentTaskScreen.routeName) {
            final int index = (settings.arguments! as Map)['index'] as int;
            final bool wasSuspended =
                (settings.arguments! as Map)['wasSuspended'] as bool;
            final String superProjectName =
                (settings.arguments! as Map)['superProjectName'] as String;
            final String superProjectId =
                (settings.arguments! as Map)['superProjectId'] as String;
            return MaterialPageRoute(builder: (context) {
              return CurrentTaskScreen(
                index: index,
                wasSuspended: wasSuspended,
                superProjectName: superProjectName,
                superProjectId: superProjectId,
                navigatorKey: navigatorKey,
                key: taskKey,
              );
            });
          } else if (settings.name == CurrentGoalScreen.routeName) {
            final int index = settings.arguments! as int;
            return MaterialPageRoute(builder: (context) {
              return CurrentGoalScreen(
                index: index,
              );
            });
          } else if (settings.name == TabsScreen.routeName) {
            final int selected = settings.arguments! as int;
            return MaterialPageRoute(builder: (context) {
              return TabsScreen(selected);
            });
          } else if (settings.name == CurrentProjectScreen.routeName) {
            final String id =
                (settings.arguments! as Map)['projectId'] as String;
            final int index = (settings.arguments! as Map)['index'] as int;
            final bool? isFromClients =
                (settings.arguments! as Map)['isFromClients'] as bool?;
            return MaterialPageRoute(builder: (context) {
              return CurrentProjectScreen(
                projectId: id,
                index: index,
                isFromClients: isFromClients ?? false,
              );
            });
          }
        },
      ),
    );
  }
}
