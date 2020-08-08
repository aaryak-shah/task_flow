import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/goals.dart';
import './goals_screen.dart';
import '../widgets/plus_btn_controllers.dart';
import '../providers/tasks.dart';
import '../widgets/main_drawer.dart';
import './projects_screen.dart';
import './stats_screen.dart';
import './tasks_screen.dart';

// Screen that displays all the tabs
class TabsScreen extends StatefulWidget {
  // Arguments => selected: The index of the selected tab to be highlighted
  static const routeName = '/tabs-screen';
  final int selected;
  TabsScreen(this.selected);
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<dynamic> _pages;
  int _selectedIndex;
  bool _isInit = true;

  List<dynamic> _tabColors;

  void setGreen() {
    // function that sets the tab of index 'selected' as the accent colour
    _tabColors[_selectedIndex] = Colors.lightGreenAccent;
    for (int i = 0; i < 3; i++) {
      if (i != _selectedIndex) {
        _tabColors[i] = Colors.grey;
      }
    }
  }

  Widget navBtn(
    int selfIndex,
    IconData icon,
    String title,
    Function callback,
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
                color: _tabColors[selfIndex],
              ),
              Text(
                title,
                style: TextStyle(
                  color: _tabColors[selfIndex],
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
    _tabColors = [];
    for (int i = 0; i < 3; i++) {
      if (i == _selectedIndex) {
        _tabColors.add(Colors.lightGreenAccent);
      } else {
        _tabColors.add(Colors.grey);
      }
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<Tasks>(context).loadData();
      Provider.of<Goals>(context).loadData();
      Provider.of<Tasks>(context).purgeOldTasks();
      Provider.of<Goals>(context).purgeOldGoals();
      Provider.of<Tasks>(context).syncEngine();
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
          text: new TextSpan(children: <TextSpan>[
            new TextSpan(
              text: 'TASK',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
              ),
            ),
            new TextSpan(
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
            icon: Icon(Icons.equalizer),
            onPressed: () {
              Navigator.of(context).pushNamed(StatsScreen.routeName);
            },
            enableFeedback: false,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            const BoxShadow(
              blurRadius: 30,
              spreadRadius: 30,
              color: Colors.black26,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0), topRight: Radius.circular(0)),
          child: BottomAppBar(
            color: Color(0xFF252525),
            notchMargin: -22,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                navBtn(0, Icons.timer, 'Tasks', () {
                  setState(() {
                    _selectedIndex = 0;
                    setGreen();
                  });
                }),
                navBtn(1, Icons.flag, 'Goals', () {
                  setState(() {
                    _selectedIndex = 1;
                    setGreen();
                  });
                }),
                navBtn(2, Icons.category, 'Projects', () {
                  setState(() {
                    _selectedIndex = 2;
                    setGreen();
                  });
                }),
                SizedBox(
                  width: 75,
                ),
              ],
            ),
            shape: CircularNotchedRectangle(),
          ),
        ),
      ),
      // Plus button
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: FloatingActionButton(
          child: Icon(
            Icons.add,
            size: 35,
          ),
          backgroundColor: Color(0xFF252525),
          foregroundColor: Theme.of(context).accentColor,
          onPressed: () => _selectedIndex == 0
              ? showNewTaskForm(context)
              : _selectedIndex == 1
                  ? showNewGoalForm(context)
                  : showNewProjectForm(context),
        ),
      ),
    );
  }
}
