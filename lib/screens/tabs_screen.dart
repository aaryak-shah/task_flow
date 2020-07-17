import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/providers/tasks.dart';
import '../widgets/main_drawer.dart';
import './projects_screen.dart';
import './stats_screen.dart';
import './tasks_screen.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<dynamic> _pages;
  int _selectedIndex = 0;

  @override
  void initState() {
    _pages = [TasksScreen(), ProjectsScreen(), StatsScreen()];
    super.initState();
  }

  @override
  void didChangeDependencies() {
    Provider.of<Tasks>(context).loadData();
    super.didChangeDependencies();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        title: Text(
          'TASKFLOW',
          style: Theme.of(context).appBarTheme.textTheme.headline6,
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 5,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Theme.of(context).accentColor,
        currentIndex: _selectedIndex,
        onTap: _selectPage,
        backgroundColor: Color(0xFF252525),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.av_timer),
            title: Text('Tasks'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            title: Text('Projects'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.equalizer),
            title: Text('Stats'),
          ),
        ],
      ),
    );
  }
}
