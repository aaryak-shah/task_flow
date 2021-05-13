import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

enum SyncStatus { fullySynced, newTask, updatedTask }

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
    this.syncStatus = SyncStatus.newTask,
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
      return DateTime.now().difference(start) - pauseTime;
    }
  }

  String getTimeString(String mode, {required bool showSeconds}) {
    // Arguments => mode: Mode in which the function runs, either 'run' or 'goal'
    //
    // returns the time as a formatted string
    // if mode is 'run', it gets the running time for the task
    // if mode is 'goal', it returns zero

    final Duration getTime = mode == 'run'
        ? getRunningTime()
        : mode == 'goal'
            ? goalTime
            : Duration.zero;
    String h, m, s;
    final int time = getTime.inSeconds;
    final int hrs = (time / 3600).floor();
    final int mins = ((time / 60).floor()) % 60;
    final int seconds = time % 60;
    (hrs / 10).floor() == 0 ? h = '0$hrs:' : h = '$hrs:';
    (mins / 10).floor() == 0 ? m = '0$mins' : m = mins.toString();
    (seconds / 10).floor() == 0 ? s = ':0$seconds' : s = ':$seconds';
    return h + m + (showSeconds ? s : '');
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
    final File csvFile = await _localFile;
    final String csvString = await csvFile.readAsString();
    final List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(csvString);

    final DateFormat parser = DateFormat("dd-MM-yyyy HH:mm:ss");
    final rows = rowsAsListOfValues.map((row) {
      return Task(
          id: row[0] as String,
          title: row[1] as String,
          start: parser.parse(row[2] as String),
          latestPause: (row[3] as String).isNotEmpty
              ? parser.parse(row[3] as String)
              : null,
          end: (row[4] as String).isNotEmpty
              ? parser.parse(row[4] as String)
              : null,
          pauses: row[5] as int,
          pauseTime: Duration(seconds: row[6] as int),
          isRunning: row[7] == 1,
          isPaused: row[8] == 1,
          category: row[9] as String,
          labels: (row[10] as String).split(" "),
          goalTime: Duration(seconds: row[11] as int),
          syncStatus: SyncStatus.values[row[12] as int]);
    }).toList();
    return rows;
  }

  Future<int> get getIndex async {
    // getter that gets the index of this task in the tasks list
    final t = await tasks;
    return t.indexWhere((t) => t.id == id);
  }
}
