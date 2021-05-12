import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/providers/settings.dart';
import 'package:task_flow/providers/theme_switcher.dart';
import 'package:task_flow/widgets/plus_btn_controllers.dart';

import '../widgets/chart.dart';
import '../providers/tasks.dart';
import 'current_task_screen.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int selectedDay = 6;
  Widget chartBtn(int i, bool shorten) {
    return Container(
      height: shorten ? 100 : 200,
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
                Consumer<Settings>(
                  builder: (context, settings, _) => Container(
                    height: settings.shortTaskChart ? 115 : 230,
                    child: Stack(
                      alignment: Alignment.center,
                      fit: StackFit.expand,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            boxShadow: [
                              Provider.of<ThemeModel>(context)
                                  .bottomFallingShadow,
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
                              chartBtn(0, settings.shortTaskChart),
                              chartBtn(1, settings.shortTaskChart),
                              chartBtn(2, settings.shortTaskChart),
                              chartBtn(3, settings.shortTaskChart),
                              chartBtn(4, settings.shortTaskChart),
                              chartBtn(5, settings.shortTaskChart),
                              chartBtn(6, settings.shortTaskChart),
                            ],
                          ),
                        )
                      ],
                    ),
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
                          color: Theme.of(context).unselectedWidgetColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        ' ${(tasks.weekTasks[selectedDay]['time'] as Duration).inHours}h ${(tasks.weekTasks[selectedDay]['time'] as Duration).inMinutes.remainder(60)}min',
                        style: TextStyle(
                          color: Theme.of(context).unselectedWidgetColor,
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
                            tsk.latestPause?.day ==
                            DateTime.now()
                                .subtract(Duration(days: 6 - selectedDay))
                                .day)
                        .length,
                    itemBuilder: (ctx, index) {
                      final t = tasks.recentTasks.reversed
                          .where((tsk) =>
                              tsk.latestPause?.day ==
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
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color,
                                  ),
                                )
                              : IconButton(
                                  onPressed: () async {
                                    Navigator.of(context).pushReplacementNamed(
                                        CurrentTaskScreen.routeName,
                                        arguments: {
                                          'index': await t.getIndex,
                                          'wasSuspended': false,
                                          'superProjectName': '',
                                          'superProjectId': '',
                                        });
                                  },
                                  icon: Icon(
                                    Icons.play_arrow,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color,
                                  ),
                                ),
                          title: Text(
                            t.title.length <= 40
                                ? t.title
                                : (t.title.substring(0, 40) + '...'),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(
                                  fontWeight: t.end == null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: (t.end != null)
                                      ? Theme.of(context).unselectedWidgetColor
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .color,
                                ),
                          ),
                          subtitle: Text(
                            tasks.categoryString(t.id),
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          trailing: Consumer<Settings>(
                            builder: (context, settings, _) => Text(
                              t.end == null
                                  ? t.getTimeString('run', settings.showSeconds)
                                  : 'Completed',
                            ),
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
