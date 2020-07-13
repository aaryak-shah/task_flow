import 'package:flutter/material.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        children: <Widget>[
          Container(
            child: Text(
              'data',
              style: Theme.of(context).textTheme.bodyText1,
            ), //TODO: Add Chart Widget Here,
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
