import 'package:flutter/material.dart';
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

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Center(
          child: Text(
            'TASKFLOW',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        child: BottomNavigationBar(
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
      ),
    );
  }
}
