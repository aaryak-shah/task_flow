import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/chart.dart';
import '../providers/tasks.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

void showNewTaskForm(BuildContext context) {
  final tasks = Provider.of<Tasks>(context, listen: false);
  showModalBottomSheet(
      context: context,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: Container(),
          behavior: HitTestBehavior.opaque,
        );
      });
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<Tasks>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Chart(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'YOUR TASKS',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Text(
                'hh:mm',
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
                    debugPrint(
                        'presed play on ' + tasks.visibleTasks[index].title);
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
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            size: 35,
          ),
          backgroundColor: Color(0xFF252525),
          foregroundColor: Theme.of(context).accentColor,
          onPressed: () => showNewTaskForm(context)),
    );
  }
}
