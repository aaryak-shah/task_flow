import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './task.dart';

class Goals with ChangeNotifier {
  
  // DUMMY DATA
  // List<Task> _goals = [
  //   Task(
  //     id: '1',
  //     title: 'Math Homework',
  //     start: DateTime(2020, 7, 25, 1, 30, 0),
  //     end: DateTime(2020, 7, 25, 2, 35, 0),
  //     category: 'Academics',
  //     labels: ['Erwin Kreyszig', 'Vectors', 'Maths'],
  //     superProjectName: null,
  //     goalTime: Duration(hours: 1),
  //   ),
  //   Task(
  //     id: '2',
  //     title: 'Physics Homework',
  //     start: DateTime(2020, 7, 25, 4, 45, 0),
  //     end: DateTime(2020, 7, 25, 6, 0, 0),
  //     category: 'Academics',
  //     labels: ['Physics', 'Semiconductors'],
  //     superProjectName: null,
  //     goalTime: Duration(hours: 1, minutes: 30),
  //   ),
  // ];

  List<Task> _goals;

  List<Task> get goals {
    // goals getter, gives a copy of _goals
    return _goals == null ? null : [..._goals];
  }

  Future<String> get _localPath async {
    // gets the AppData directory
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    // gets the tasks.csv file from the AppData directory
    final path = await _localPath;
    return File('$path/tasks.csv');
  }

  Future<void> loadData() async {
    // function to load the data from the tasks.csv file into Task
    // models which are then put into the _goals list

    String csvPath = await _localPath;
    String csvString = await File('$csvPath/tasks.csv').readAsString();
    // String csvString = await rootBundle.loadString('assets/data/tasks.csv');
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(csvString);

    DateFormat parser = DateFormat("dd-MM-yyyy HH:mm:ss");

    _goals = rowsAsListOfValues.map((row) {
      return Task(
        id: row[0],
        title: row[1],
        start: parser.parse(row[2]),
        latestPause: row[3].isNotEmpty ? parser.parse(row[3]) : null,
        end: row[4].isNotEmpty ? parser.parse(row[4]) : null,
        pauses: row[5],
        pauseTime: Duration(seconds: row[6]),
        isRunning: row[7] == 1,
        isPaused: row[8] == 1,
        category: row[9],
        labels: row[10].split("|"),
        superProjectName: row[11],
        goalTime: Duration(seconds: row[12]),
      );
    }).toList();
    notifyListeners();
  }

  Future<void> writeCsv(List<Task> goals) async {
    // Arguments => goals: a list of Task objects to be written to the tasks.csv file

    final rows = ListToCsvConverter().convert(goals
        .map((g) => [
              g.id,
              g.title,
              DateFormat("dd-MM-yyyy HH:mm:ss").format(g.start),
              g.latestPause != null
                  ? DateFormat("dd-MM-yyyy HH:mm:ss").format(g.latestPause)
                  : "",
              g.end != null
                  ? DateFormat("dd-MM-yyyy HH:mm:ss").format(g.end)
                  : "",
              g.pauses,
              g.pauseTime.inSeconds,
              g.isRunning ? 1 : 0,
              g.isPaused ? 1 : 0,
              g.category,
              g.labels.join("|"),
              g.superProjectName == null ? "" : g.superProjectName,
              g.goalTime.inSeconds,
            ])
        .toList());
    File f = await _localFile;
    await f.writeAsString(rows, mode: FileMode.writeOnly);
    notifyListeners();
  }

  Future<void> addGoal(
    final String id,
    final String title,
    final DateTime start,
    final String category,
    final List<String> labels,
    final String superProjectName,
    final Duration goalTime,
  ) async {
    // Arguments => id: The id of the goal to be added,
    //              title: Title of the goal to be added,
    //              start: DateTime object of the start of the goal to be added,
    //              category: Category of the goal to be added,
    //              labels: List of labels of the goal to be added,
    //              superProjectName: Name of the project the goal to be added is under,
    //              goalTime: Duration of time the goal is set for
    //
    // Adds the Task object with the above arguments to the _goals list
    // and also to the tasks.csv file

    final goal = Task(
      id: id,
      title: title,
      start: start,
      category: category,
      labels: labels,
      superProjectName: superProjectName,
      goalTime: goalTime,
    );

    final row = const ListToCsvConverter().convert(
      [
        [
          id,
          title,
          DateFormat("dd-MM-yyyy HH:mm:ss").format(start),
          "",
          "",
          0,
          0,
          1,
          0,
          category,
          labels.join("|"),
          "",
          0,
        ],
      ],
    );
    File f = await _localFile;
    await f.writeAsString(row, mode: FileMode.append, flush: true);
    _goals.add(goal);
    notifyListeners();
  }

  List<Task> get recentGoals {
    // gets a list of paused goals whose start is within the past 7 days

    final recent = goals.where((g) {
      return g.goalTime > Duration.zero &&
          g.end != null &&
          g.start.isAfter(DateTime.now().subtract(Duration(days: 7)));
    });
    return recent.toList();
  }

  String categoryString(String cid) {
    // Arguments => cid: String id of the task whose category is needed
    // Returns => category of the task with id as cid

    return _goals[_goals.indexWhere((g) => cid == g.id)].category;
  }

  Future<void> complete(int index) async {
    // Arguments => index: The index of the goal to be marked as complete
    // Ends the goal at 'index' in the _goals list

    _goals[index].isRunning = false;
    _goals[index].isPaused = true;
    _goals[index].end = DateTime.now();
    await writeCsv(_goals);
    notifyListeners();
  }

  // List<Map<String, Object>> get weekGoals {
  //   return List.generate(7, (index) {
  //     final weekDay = DateTime.now().subtract(Duration(days: index));
  //     Duration total = Duration();

  //     for (int i = 0; i < recentGoals.length; i++) {
  //       if (recentGoals[i].latestPause.day == weekDay.day &&
  //           recentGoals[i].latestPause.month == weekDay.month &&
  //           recentGoals[i].latestPause.year == weekDay.year) {
  //         total += (recentGoals[i].getRunningTime());
  //       }
  //     }

  //     return {'day': index, 'time': total};
  //   }).reversed.toList();
  // }

  // Duration get totalTime {
  //   Duration time;
  //   recentGoals.forEach((goal) {
  //     time += goal.
  //   });
  // }

  Future<void> addLabels(
      int index, 
      List<String> selected, 
      List<String> labels,
    ) async {
    // Arguments => index: The index of the goal in the list to which the labels are to be added,
    //              selected: The list of labels to be added to the goal,
    //              labels: The list of available labels (shown as chips),
    //
    // Adds 'selected' labels to the goal at 'index' in the _goals list
    // Also updates the 'AvailableLabels' key in SharedPreferences

    _goals[index].labels.addAll(selected);
    _goals[index].labels = _goals[index].labels.toSet().toList();
    await writeCsv(_goals);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('AvailableLabels', labels);
    notifyListeners();
  }

  Future<List<String>> get availableLabels async {
    // getter to fetch the list of available labels from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('AvailableLabels') ?? [];
  }

    Future<void> purgeOldGoals() async {
    // function to delete (purge) goals which have a latest pause date
    // older than 1 week so as to save space and computation time

    await loadData();
    _goals.removeWhere((goal) {
      return goal.start.isBefore(
        DateTime.now().subtract(
          Duration(
            days: 7,
          ),
        ),
      );
    });
    await writeCsv(_goals);
    notifyListeners();
  }
}