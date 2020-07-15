import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import './task.dart';

class Tasks with ChangeNotifier {
  List<Task> _tasks;
  //   Task(
  //     id: 't1',
  //     title: 'Math Homework',
  //     start: DateTime(2020, 7, 13, 8, 20, 0),
  //     categories: ['College', 'Math'],
  //     labels: ['BS Grewal'],
  //     superProjectName: null,
  //     isRunning: false,
  //     isPaused: true,
  //     latestPause: DateTime(2020, 7, 13, 10, 0, 0),
  //     end: DateTime(2020, 7, 13, 10, 0, 0),
  //   ),
  //   Task(
  //     id: 't2',
  //     title: 'DE Homework',
  //     start: DateTime(2020, 7, 14, 10, 5, 0),
  //     categories: ['College', 'Electronics'],
  //     labels: [],
  //     superProjectName: null,
  //     isRunning: false,
  //     isPaused: true,
  //     latestPause: DateTime(2020, 7, 14, 10, 40, 0),
  //   ),
  //   Task(
  //     id: 't3',
  //     title: 'Sketching Practise',
  //     start: DateTime(2020, 7, 14, 12, 30, 0),
  //     categories: ['Personal', 'Art'],
  //     labels: ['Sketching'],
  //     superProjectName: null,
  //     isRunning: false,
  //     isPaused: true,
  //     latestPause: DateTime(2020, 7, 14, 14, 42, 0),
  //     end: DateTime(2020, 7, 14, 14, 42, 0),
  //   ),
  //   Task(
  //     id: 't4',
  //     title: 'C++ Practise',
  //     start: DateTime(2020, 7, 14, 15, 0, 0),
  //     categories: ['College', 'Computers'],
  //     labels: ['C++'],
  //     superProjectName: null,
  //     isRunning: false,
  //     isPaused: true,
  //     latestPause: DateTime(2020, 7, 14, 15, 50, 0),
  //   ),
  //   Task(
  //     id: 't5',
  //     title: 'House Chores',
  //     start: DateTime(2020, 7, 14, 16, 0, 0),
  //     categories: ['Personal'],
  //     labels: [],
  //     superProjectName: null,
  //     isRunning: false,
  //     isPaused: true,
  //     latestPause: DateTime(2020, 7, 14, 17, 0, 0),
  //   ),
  //   Task(
  //     id: 't6',
  //     title: 'Cook Dinner',
  //     start: DateTime(2020, 7, 14, 19, 0, 0),
  //     categories: ['Cooking'],
  //     labels: [],
  //     superProjectName: null,
  //     isRunning: false,
  //     isPaused: true,
  //     latestPause: DateTime(2020, 7, 14, 19, 54, 0),
  //   ),
  //   Task(
  //     id: 't7',
  //     title: 'Data Science Course',
  //     start: DateTime(2020, 7, 14, 20, 0, 0),
  //     categories: ['Personal', 'Computers'],
  //     labels: ['Udemy'],
  //     superProjectName: null,
  //     isRunning: true,
  //     isPaused: false,
  //     latestPause: DateTime(2020, 7, 14, 21, 30, 0),
  //   ),
  // ];

  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  void loadData() async {
    String csvString = await rootBundle.loadString('assets/data/tasks.csv');
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(csvString).sublist(1);

    DateFormat parser = DateFormat("dd-MM-yyyy HH:mm:ss");

    _tasks = rowsAsListOfValues.map((row) {
      return Task(
        id: row[0],
        title: row[1],
        start: parser.parse(row[2]),
        latestPause: row[3].isNotEmpty ? parser.parse(row[3]) : null,
        end: row[4].isNotEmpty ? parser.parse(row[4]) : null,
        pauses: row[5],
        pauseTime: Duration(minutes: row[6]),
        isRunning: row[7] == 1,
        isPaused: row[8] == 1,
        categories: row[9].split(" "),
        labels: row[10].split(" "),
        superProjectName: row[11],
      );
    }).toList();

    notifyListeners();
  }

  List<Task> get tasks {
    final t = _tasks == null ? null : [..._tasks];
    return t;
  }

  List<Task> get visibleTasks {
    return tasks.where((task) => task.isPaused).toList();
  }

  List<Task> get recentTasks {
    final recent = tasks.where((t) {
      return t.isPaused &&
          t.latestPause.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
    // notifyListeners();
    return recent;
  }

  List<Map<String, Object>> get weekTasks {
    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(Duration(days: index));
      Duration total = Duration();

      for (int i = 0; i < recentTasks.length; i++) {
        if (recentTasks[i].latestPause.day == weekDay.day &&
            recentTasks[i].latestPause.month == weekDay.month &&
            recentTasks[i].latestPause.year == weekDay.year) {
          total += (recentTasks[i].getRunningTime());
        }
      }

      return {'day': index, 'time': total};
    }).reversed.toList();
  }

  Duration get totalTime {
    return weekTasks.fold(
        Duration(), (previousSum, day) => previousSum + day['time']);
  }

  String categoriesString(String cid) {
    String catString = '';
    List<String> cats =
        _tasks[_tasks.indexWhere((tsk) => cid == tsk.id)].categories;
    for (int i = 0; i < cats.length; i++) {
      if (i < cats.length - 1) {
        catString += cats[i] + ', ';
      } else {
        catString += cats[i];
      }
    }
    return catString;
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
