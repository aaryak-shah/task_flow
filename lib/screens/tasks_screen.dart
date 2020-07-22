import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/chart.dart';
import '../widgets/new_task.dart';
import '../providers/tasks.dart';
import '../screens/current_task.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

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
      });
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
          debugPrint(i.toString());
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
                    itemBuilder: (ctx, index) => Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: ListTile(
                        leading: IconButton(
                          onPressed: (tasks.recentTasks.reversed
                                      .where((tsk) =>
                                          tsk.latestPause.day ==
                                          DateTime.now()
                                              .subtract(Duration(
                                                  days: 6 - selectedDay))
                                              .day)
                                      .toList()[index]
                                      .end !=
                                  null)
                              ? null
                              : () async {
                                  Navigator.of(context).pushReplacementNamed(
                                    CurrentTaskScreen.routeName,
                                    arguments: await tasks.recentTasks.reversed
                                        .where((tsk) =>
                                            tsk.latestPause.day ==
                                            DateTime.now()
                                                .subtract(Duration(
                                                    days: 6 - selectedDay))
                                                .day)
                                        .toList()[index]
                                        .getIndex,
                                  );
                                  debugPrint('pressed play on ' +
                                      tasks.recentTasks.reversed
                                          .where((tsk) =>
                                              tsk.latestPause.day ==
                                              DateTime.now()
                                                  .subtract(Duration(
                                                      days: 6 - selectedDay))
                                                  .day)
                                          .toList()[index]
                                          .title);
                                },
                          icon: Icon(
                            Icons.play_arrow,
                            color: (tasks.recentTasks.reversed
                                        .where((tsk) =>
                                            tsk.latestPause.day ==
                                            DateTime.now()
                                                .subtract(Duration(
                                                    days: 6 - selectedDay))
                                                .day)
                                        .toList()[index]
                                        .end !=
                                    null)
                                ? Colors.grey
                                : Colors.white,
                          ),
                        ),
                        title: Text(
                          tasks.recentTasks.reversed
                                      .where((tsk) =>
                                          tsk.latestPause.day ==
                                          DateTime.now()
                                              .subtract(Duration(
                                                  days: 6 - selectedDay))
                                              .day)
                                      .toList()[index]
                                      .title
                                      .length <=
                                  40
                              ? tasks.recentTasks.reversed
                                  .where((tsk) =>
                                      tsk.latestPause.day ==
                                      DateTime.now()
                                          .subtract(
                                              Duration(days: 6 - selectedDay))
                                          .day)
                                  .toList()[index]
                                  .title
                              : (tasks.recentTasks.reversed
                                      .where((tsk) =>
                                          tsk.latestPause.day ==
                                          DateTime.now()
                                              .subtract(Duration(
                                                  days: 6 - selectedDay))
                                              .day)
                                      .toList()[index]
                                      .title
                                      .substring(0, 40) +
                                  '...'),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: (tasks.recentTasks.reversed
                                            .where((tsk) =>
                                                tsk.latestPause.day ==
                                                DateTime.now()
                                                    .subtract(Duration(
                                                        days: 6 - selectedDay))
                                                    .day)
                                            .toList()[index]
                                            .end !=
                                        null)
                                    ? Colors.grey
                                    : Colors.white,
                              ),
                        ),
                        subtitle: Text(
                          tasks.categoryString(tasks.recentTasks.reversed
                              .where((tsk) =>
                                  tsk.latestPause.day ==
                                  DateTime.now()
                                      .subtract(Duration(days: 6 - selectedDay))
                                      .day)
                              .toList()[index]
                              .id),
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        trailing: Text(
                          tasks.recentTasks.reversed
                              .where((tsk) =>
                                  tsk.latestPause.day ==
                                  DateTime.now()
                                      .subtract(Duration(days: 6 - selectedDay))
                                      .day)
                              .toList()[index]
                              .getRunningTimeString(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              //   floatingActionButtonLocation:
              //       FloatingActionButtonLocation.centerFloat,
              //   floatingActionButton: FloatingActionButton(
              //     child: Icon(
              //       Icons.add,
              //       size: 35,
              //     ),
              //     backgroundColor: Color(0xFF252525),
              //     foregroundColor: Theme.of(context).accentColor,
              //     onPressed: () => showNewTaskForm(context),
            ),
          );
  }
}
