import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/providers/tasks.dart';
import '../widgets/main_drawer.dart';
import './projects_screen.dart';
import './stats_screen.dart';
import './tasks_screen.dart';
import '../widgets/new_task.dart';

void showNewTaskForm(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (_) {
      return GestureDetector(
        onTap: () {},
        child: NewTask(),
        behavior: HitTestBehavior.opaque,
      );
    },
  );
}

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<dynamic> _pages;
  int _selectedIndex = 0;
  bool _isInit = true;

  List<dynamic> _tabColors;

  void setGreen() {
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
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: callback,
        child: Container(
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
    _pages = [
      TasksScreen(),
      ProjectsScreen(),
      StatsScreen(),
    ];
    _tabColors = [
      Colors.lightGreenAccent,
      Colors.grey,
      Colors.grey,
    ];
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<Tasks>(context).loadData();
      Provider.of<Tasks>(context).purgeOldTasks();
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
          )
          // actions: <Widget>[
          //   IconButton(
          //     icon: Icon(Icons.equalizer),
          //     onPressed: () {},
          //     enableFeedback: false,
          //   ),
          // ],
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
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          child: BottomAppBar(
            color: Color(0xFF252525),
            notchMargin: -22,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  width: 0,
                ),
                navBtn(0, Icons.av_timer, 'Tasks', () {
                  setState(() {
                    _selectedIndex = 0;
                    setGreen();
                  });
                }),
                navBtn(1, Icons.category, 'Projects', () {
                  setState(() {
                    _selectedIndex = 1;
                    setGreen();
                  });
                }),
                navBtn(2, Icons.equalizer, 'Stats', () {
                  setState(() {
                    _selectedIndex = 2;
                    setGreen();
                  });
                }),
                _selectedIndex != 2
                    ? SizedBox(
                        width: 75,
                      )
                    : SizedBox(
                        width: 0.0,
                      ),
              ],
            ),
            shape: CircularNotchedRectangle(),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _selectedIndex == 2
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: FloatingActionButton(
                child: Icon(
                  Icons.add,
                  size: 35,
                ),
                backgroundColor: Color(0xFF252525),
                foregroundColor: Theme.of(context).accentColor,
                onPressed: () => showNewTaskForm(context),
              ),
            ),

      // bottomNavigationBar: BottomNavigationBar(
      //   elevation: 5,
      //   unselectedItemColor: Colors.grey,
      //   selectedItemColor: Theme.of(context).accentColor,
      //   currentIndex: _selectedIndex,
      //   onTap: _selectPage,
      //   backgroundColor: Color(0xFF252525),
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.av_timer),
      //       title: Text('Tasks'),
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.category),
      //       title: Text('Projects'),
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.equalizer),
      //       title: Text('Stats'),
      //     ),
      //   ],
      // ),
    );
  }
}
