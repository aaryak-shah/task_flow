import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/widgets/plus_btn_controllers.dart';

import '../widgets/chart.dart';
import '../providers/tasks.dart';
import '../screens/current_task.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int selectedDay = 6;
  Widget chartBtn(int i) {
    return Container(
      height: 200,
      width: 30,
      color: Color(0x00000000),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedDay = i;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<Tasks>(context);
    return tasks.tasks == null
        ? Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
          )
        : Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: Column(
              children: <Widget>[
                Container(
                  height: 230,
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 60,
                                spreadRadius: 60,
                                offset: Offset(0, 60))
                          ],
                        ),
                        padding: const EdgeInsets.only(top: 10),
                        child: Chart(selectedDay),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            chartBtn(0),
                            chartBtn(1),
                            chartBtn(2),
                            chartBtn(3),
                            chartBtn(4),
                            chartBtn(5),
                            chartBtn(6),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'YOUR TASKS  - ',
                        style: TextStyle(
                          color: Colors.white38,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        ' ${(tasks.weekTasks[selectedDay]['time'] as Duration).inHours}h ${(tasks.weekTasks[selectedDay]['time'] as Duration).inMinutes.remainder(60)}min',
                        style: TextStyle(
                          color: Colors.white38,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.recentTasks.reversed
                        .where((tsk) =>
                            tsk.latestPause.day ==
                            DateTime.now()
                                .subtract(Duration(days: 6 - selectedDay))
                                .day)
                        .length,
                    itemBuilder: (ctx, index) {
                      final t = tasks.recentTasks.reversed
                          .where((tsk) =>
                              tsk.latestPause.day ==
                              DateTime.now()
                                  .subtract(Duration(days: 6 - selectedDay))
                                  .day)
                          .toList()[index];
                      return Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: ListTile(
                          leading: (t.end != null)
                              ? IconButton(
                                  onPressed: () {
                                    showEditTaskForm(
                                        context, [t.title, t.category]);
                                  },
                                  icon: Icon(
                                    Icons.refresh,
                                  ),
                                )
                              : IconButton(
                                  onPressed: () async {
                                    Navigator.of(context).pushReplacementNamed(
                                        CurrentTaskScreen.routeName,
                                        arguments: {
                                          'index': await t.getIndex,
                                          'wasSuspended': false
                                        });
                                  },
                                  icon: Icon(
                                    Icons.play_arrow,
                                    color: (t.end != null)
                                        ? Colors.grey
                                        : Colors.white,
                                  ),
                                ),
                          title: Text(
                            t.title.length <= 40
                                ? t.title
                                : (t.title.substring(0, 40) + '...'),
                            style:
                                Theme.of(context).textTheme.bodyText1.copyWith(
                                      fontWeight: t.end == null
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: (t.end != null)
                                          ? Colors.grey
                                          : Colors.white,
                                    ),
                          ),
                          subtitle: Text(
                            tasks.categoryString(t.id),
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          trailing: Text(
                            t.end == null
                                ? t.getTimeString('run')
                                : 'Completed',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}
