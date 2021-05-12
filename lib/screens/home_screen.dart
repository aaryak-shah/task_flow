import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/providers/theme_switcher.dart';
import 'package:task_flow/screens/clients_screen.dart';
import 'package:task_flow/screens/current_goal_screen.dart';
import 'package:task_flow/screens/current_project_screen.dart';
import 'package:task_flow/screens/current_task_screen.dart';
import 'package:task_flow/screens/profile_screen.dart';
import 'package:task_flow/screens/settings_screen.dart';
import 'package:task_flow/screens/stats_screen.dart';
import 'package:task_flow/screens/tabs_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
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
            final int index = settings.arguments as int;
            return MaterialPageRoute(builder: (context) {
              return CurrentGoalScreen(
                index: index,
              );
            });
          } else if (settings.name == TabsScreen.routeName) {
            final int selected = settings.arguments as int;
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
