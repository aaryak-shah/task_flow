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
