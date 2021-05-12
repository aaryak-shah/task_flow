import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

enum SyncStatus { FullySynced, NewTask, UpdatedTask }

class Task {
  // creating a model for Task objects
  SyncStatus syncStatus;
  String id;
  final String title;
  final DateTime start;
  DateTime? latestPause;
  DateTime? end;
  int pauses;
  Duration pauseTime;
  bool isRunning;
  bool isPaused;
  final String category;
  List<String>? labels;
  final Duration goalTime;

  Task({
    this.syncStatus = SyncStatus.NewTask,
    required this.id,
    required this.title,
    required this.start,
    this.latestPause,
    this.end,
    this.pauses = 0,
    this.pauseTime = Duration.zero,
    this.isRunning = true,
    this.isPaused = false,
    required this.category,
    this.labels,
    this.goalTime = Duration.zero,
  });

  Duration getRunningTime() {
    // function to get the total time this task has been running for
    // excluding pause time
    if (end != null) {
      return (end ?? DateTime.now()).difference(start) - pauseTime;
    } else if (isPaused) {
      return (latestPause ?? DateTime.now()).difference(start) - pauseTime;
    } else {
      return (DateTime.now().difference(start) - pauseTime);
    }
  }

  String getTimeString(String mode, bool showSeconds) {
    // Arguments => mode: Mode in which the function runs, either 'run' or 'goal'
    //
    // returns the time as a formatted string
    // if mode is 'run', it gets the running time for the task
    // if mode is 'goal', it returns zero

    Duration getTime = mode == 'run'
        ? getRunningTime()
        : mode == 'goal'
            ? goalTime
            : Duration.zero;
    String h, m, s;
    int time = getTime.inSeconds;
    int hrs = (time / 3600).floor();
    int mins = (time / 60).floor();
    int seconds = time % 60;
    (hrs / 10).floor() == 0
        ? h = '0' + hrs.toString() + ':'
        : h = hrs.toString() + ':';
    (mins / 10).floor() == 0 ? m = '0' + mins.toString() : m = mins.toString();
    (seconds / 10).floor() == 0
        ? s = ':0' + seconds.toString()
        : s = ':' + seconds.toString();
    return (h + m + (showSeconds ? s : ''));
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

  Future<List<Task>> get tasks async {
    // getter to read the tasks.csv file and get a list of Task objects
    File csvFile = await _localFile;
    String csvString = await csvFile.readAsString();
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(csvString);

    DateFormat parser = DateFormat("dd-MM-yyyy HH:mm:ss");
    var rows = rowsAsListOfValues.map((row) {
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
          labels: row[10].split(" "),
          goalTime: Duration(seconds: row[11]),
          syncStatus: SyncStatus.values[row[12]]);
    }).toList();
    return rows;
  }

  Future<int> get getIndex async {
    // getter that gets the index of this task in the tasks list
    var t = await tasks;
    return t.indexWhere((t) => t.id == id);
  }
}
