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
    final tasks =  Provider.of<Tasks>(context);
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
        ],
      ),
    );
  }
}
