import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/chart.dart';
import '../widgets/new_task.dart';
import '../providers/tasks.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

void showNewTaskForm(BuildContext context) {
  showModalBottomSheet(
      context: context,
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
      height: double.infinity,
      width: 55,
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
                  height: 200,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Chart(),
                      ),
                      Row(
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
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      'YOUR TASKS',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Text(
                      '${(tasks.weekTasks[selectedDay]['time'] as Duration).inHours}h ${(tasks.weekTasks[selectedDay]['time'] as Duration).inMinutes.remainder(60)}min',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.visibleTasks.length,
                    itemBuilder: (ctx, index) => ListTile(
                      leading: IconButton(
                        onPressed: () {
                          debugPrint('presed play on ' +
                              tasks.visibleTasks[index].title);
                        },
                        icon: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        tasks.visibleTasks[index].title,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      subtitle: Text(
                        tasks.categoriesString(tasks.visibleTasks[index].id),
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      trailing: Text(
                        tasks.visibleTasks[index].getRunningTimeString(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
                size: 35,
              ),
              backgroundColor: Color(0xFF252525),
              foregroundColor: Theme.of(context).accentColor,
              onPressed: () => showNewTaskForm(context),
            ),
          );
  }
}
