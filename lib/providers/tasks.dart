import 'package:flutter/foundation.dart';
import './task.dart';

class Tasks with ChangeNotifier {
  List<Task> _tasks = [
    Task(
      id: 't1',
      title: 'Math Homework',
      start: DateTime.now(),
      categories: ['School'],
      labels: [],
      superProjectName: null,
      isRunning: true,
    ),
    Task(
        id: 't2',
        title: 'Math Homework',
        start: DateTime(2020, 7, 14, 14, 0, 0),
        categories: ['School'],
        labels: [],
        superProjectName: null,
        isRunning: false,
        isPaused: true,
        latestPause: DateTime(2020, 7, 14, 15, 0, 0))
  ];

  List<Task> get tasks {
    print(_tasks.length);
    return [..._tasks];
  }

  List<Task> get recentTasks {
    return _tasks.where((t) {
      return t.isPaused &&
          t.latestPause.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  void addTask(
    final String id,
    final String title,
    final DateTime start,
    final List<String> categories,
    final List<String> labels,
    final String superProjectName,
  ) {
    final task = Task(
      id: id,
      title: title,
      start: start,
      categories: categories,
      labels: labels,
      superProjectName: superProjectName,
    );

    _tasks.insert(0, task);
    notifyListeners();
  }
}
