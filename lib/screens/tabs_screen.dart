import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/utils/is_connected.dart';

import '../models/project.dart';
import '../providers/goals.dart';
import '../providers/projects.dart';
import '../providers/tasks.dart';
import '../providers/theme_switcher.dart';
import '../widgets/main_drawer.dart';
import '../widgets/plus_btn_controllers.dart';
import 'goals_screen.dart';
import 'projects_screen.dart';
import 'stats_screen.dart';
import 'tasks_screen.dart';

// Screen that displays all the tabs
class TabsScreen extends StatefulWidget {
  // Arguments => selected: The index of the selected tab to be highlighted
  static const routeName = '/tabs-screen';
  final int selected;
  const TabsScreen(this.selected);
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  late List<dynamic> _pages;
  int _selectedIndex = 0;
  bool _isInit = true;

  late List<dynamic> _tabColors;

  void setSelectedColor(BuildContext context) {
    // function that sets the tab of index 'selected' as the accent colour
    _tabColors[_selectedIndex] = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).accentColor
        : Colors.white;
    for (int i = 0; i < 3; i++) {
      if (i != _selectedIndex) {
        _tabColors[i] = Colors.white60;
      }
    }
  }

  Widget navBtn(
    int selfIndex,
    IconData icon,
    String title,
    void Function() callback,
  ) {
    // Arguments => selfIndex: Index of the currently selected tab
    //              icon: The icon to be used for the tab
    //              title: The title for the tab
    //              callback: The function to be executed on tapping on the tab
    //
    // Creates a tab to be displayed in the bottom navigation bar

    return GestureDetector(
      onTap: callback,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          color: Colors.transparent,
          height: 50,
          width: 75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Icon(
                icon,
                color: _tabColors[selfIndex] as Color?,
                size: selfIndex == _selectedIndex ? 28 : 24,
              ),
              Text(
                title,
                style: TextStyle(
                  color: _tabColors[selfIndex] as Color?,
                  fontWeight: selfIndex == _selectedIndex
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _selectedIndex = widget.selected;

    _pages = [
      TasksScreen(),
      GoalsScreen(),
      ProjectsScreen(),
    ];

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _tabColors = [];
      for (int i = 0; i < 3; i++) {
        if (i == _selectedIndex) {
          _tabColors.add(Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).accentColor
              : Colors.white);
        } else {
          _tabColors.add(Colors.white60);
        }
      }

      Provider.of<Tasks>(context).loadData();
      Provider.of<Goals>(context).loadData();
      Provider.of<Projects>(context).loadData();
    isConnected().then((isConnected) {
      if (isConnected) {
        Provider.of<Tasks>(context, listen: false).purgeOldTasks();
        Provider.of<Goals>(context, listen: false).purgeOldGoals();
        Provider.of<Tasks>(context, listen: false).syncEngine();
        final Projects projects = Provider.of<Projects>(context, listen: false);
        projects.syncEngine();
        for (final Project project in projects.projects) {
          project.syncEngine();
        }
      }
    });
      _isInit = false;
    }

    
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        title: RichText(
          text: TextSpan(children: <TextSpan>[
            TextSpan(
              text: 'TASK',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
            ),
            TextSpan(
              text: 'FLOW',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                color: Theme.of(context).accentColor,
              ),
            ),
          ]),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.equalizer),
            onPressed: () {
              Navigator.of(context).pushNamed(StatsScreen.routeName);
            },
            enableFeedback: false,
          ),
        ],
      ),
      body: _pages[_selectedIndex] as Widget,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            Provider.of<ThemeModel>(context).topFallingShadow,
          ],
        ),
        child: ClipRRect(
          child: BottomAppBar(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardColor
                : Theme.of(context).accentColor,
            notchMargin: -22,
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                navBtn(0, Icons.timer, 'Tasks', () {
                  setState(() {
                    _selectedIndex = 0;
                    setSelectedColor(context);
                  });
                }),
                navBtn(1, Icons.flag, 'Goals', () {
                  setState(() {
                    _selectedIndex = 1;
                    setSelectedColor(context);
                  });
                }),
                navBtn(2, Icons.category, 'Projects', () {
                  setState(() {
                    _selectedIndex = 2;
                    setSelectedColor(context);
                  });
                }),
                const SizedBox(
                  width: 75,
                ),
              ],
            ),
          ),
        ),
      ),
      // Plus button
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).cardColor
              : Theme.of(context).accentColor,
          foregroundColor: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).accentColor
              : Theme.of(context).cardColor,
          onPressed: () => _selectedIndex == 0
              ? showNewTaskForm(context)
              : _selectedIndex == 1
                  ? showNewGoalForm(context)
                  : showNewProjectForm(context),
          child: const Icon(
            Icons.add,
            size: 35,
          ),
        ),
      ),
    );
  }
}
