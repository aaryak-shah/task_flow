import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/chart.dart';
import '../providers/tasks.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
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
            child: Chart(tasks.recentTasks),
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
                  (tasks.visibleTasks[index].latestPause.hour.toString() +
                      ':' +
                      tasks.visibleTasks[index].latestPause.minute.toString()),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
