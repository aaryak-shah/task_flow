import 'dart:io';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class Goals with ChangeNotifier {
  BuildContext context;
  List<Task> _goals = [];
  Goals(this.context);

  // goals getter, gives a copy of _goals
  List<Task> get goals => [..._goals];

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

  Future<bool> get _isConnected async {
    try {
      final result = await InternetAddress.lookup(
          'https://taskflow1-4a77f.firebaseio.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
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
          title: row[1].toString(),
          start: parser.parse(row[2]),
          latestPause: row[3].isNotEmpty ? parser.parse(row[3]) : null,
          end: row[4].isNotEmpty ? parser.parse(row[4]) : null,
          pauses: row[5],
          pauseTime: Duration(seconds: row[6]),
          isRunning: row[7] == 1,
          isPaused: row[8] == 1,
          category: row[9],
          labels: row[10].split("|"),
          goalTime: Duration(seconds: row[11]),
          syncStatus: SyncStatus.values[row[12]]);
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
                  ? DateFormat("dd-MM-yyyy HH:mm:ss").format(g.latestPause!)
                  : "",
              g.end != null
                  ? DateFormat("dd-MM-yyyy HH:mm:ss").format(g.end!)
                  : "",
              g.labels == null ? null : g.labels!.join("|"),
              g.pauses,
              g.pauseTime.inSeconds,
              g.isRunning ? 1 : 0,
              g.isPaused ? 1 : 0,
              g.category,
              g.goalTime.inSeconds,
              g.syncStatus.index
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
    final Duration goalTime,
  ) async {
    // Arguments => id: The id of the goal to be added,
    //              title: Title of the goal to be added,
    //              start: DateTime object of the start of the goal to be added,
    //              category: Category of the goal to be added,
    //              labels: List of labels of the goal to be added,
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
          SyncStatus.NewTask.index
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

    final firebaseUser = context.read<User?>();
    if (await _isConnected && firebaseUser != null) {
      String? userId = firebaseUser.uid;
      String? token = (await firebaseUser.getIdTokenResult()).token;
      Uri url = Uri.parse(
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/tasks.json?auth=$token");
      await http.post(
        url,
        body: json.encode(
          {
            'id': _goals[index].id,
            'title': _goals[index].title,
            'start':
                DateFormat("dd-MM-yyyy HH:mm:ss").format(_goals[index].start),
            'end': DateFormat("dd-MM-yyyy HH:mm:ss").format(_goals[index].end!),
            'labels':
                _goals[index].labels != null && _goals[index].labels!.isNotEmpty
                    ? _goals[index].labels!.join("|")
                    : null,
            'goalTime': _goals[index].goalTime.inSeconds,
            'category': _goals[index].category,
          },
        ),
      );
    } else if (!await _isConnected) {
      _goals[index].syncStatus = SyncStatus.NewTask;
    }
    await writeCsv(_goals);
    notifyListeners();
  }

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

    _goals[index].labels?.addAll(selected);
    _goals[index].labels = _goals[index].labels?.toSet().toList();
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
