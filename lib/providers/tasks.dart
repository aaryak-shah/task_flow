import 'package:flutter/foundation.dart';
import './task.dart';

class Tasks with ChangeNotifier {
  List<Task> _tasks = [
    Task(
      id: 't1',
      title: 'Math Homework',
      start: DateTime(2020, 7, 13, 8, 20, 0),
      categories: ['College', 'Math'],
      labels: ['BS Grewal'],
      superProjectName: null,
      isRunning: false,
      isPaused: true,
      latestPause: DateTime(2020, 7, 13, 10, 0, 0),
      end: DateTime(2020, 7, 14, 10, 0, 0),
    ),
    Task(
      id: 't2',
      title: 'DE Homework',
      start: DateTime(2020, 7, 14, 10, 5, 0),
      categories: ['College', 'Electronics'],
      labels: [],
      superProjectName: null,
      isRunning: false,
      isPaused: true,
      latestPause: DateTime(2020, 7, 14, 10, 40, 0),
    ),
    Task(
      id: 't3',
      title: 'Sketching Practise',
      start: DateTime(2020, 7, 14, 12, 30, 0),
      categories: ['Personal', 'Art'],
      labels: ['Sketching'],
      superProjectName: null,
      isRunning: false,
      isPaused: true,
      latestPause: DateTime(2020, 7, 14, 14, 42, 0),
      end: DateTime(2020, 7, 14, 14, 42, 0),
    ),
    Task(
      id: 't4',
      title: 'C++ Practise',
      start: DateTime(2020, 7, 14, 15, 0, 0),
      categories: ['College', 'Computers'],
      labels: ['C++'],
      superProjectName: null,
      isRunning: false,
      isPaused: true,
      latestPause: DateTime(2020, 7, 14, 15, 50, 0),
    ),
    Task(
      id: 't5',
      title: 'House Chores',
      start: DateTime(2020, 7, 14, 16, 0, 0),
      categories: ['Personal'],
      labels: [],
      superProjectName: null,
      isRunning: false,
      isPaused: true,
      latestPause: DateTime(2020, 7, 14, 17, 0, 0),
    ),
    Task(
      id: 't6',
      title: 'Cook Dinner',
      start: DateTime(2020, 7, 14, 19, 0, 0),
      categories: ['Cooking'],
      labels: [],
      superProjectName: null,
      isRunning: false,
      isPaused: true,
      latestPause: DateTime(2020, 7, 14, 19, 54, 0),
    ),
    Task(
      id: 't7',
      title: 'Data Science Course',
      start: DateTime(2020, 7, 14, 20, 0, 0),
      categories: ['Personal', 'Computers'],
      labels: ['Udemy'],
      superProjectName: null,
      isRunning: true,
      isPaused: false,
      latestPause: DateTime(2020, 7, 14, 21, 30, 0),
    ),
  ]; 

  List<Task> get tasks {
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
