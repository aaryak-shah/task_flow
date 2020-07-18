import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Task with ChangeNotifier {
  final String id;
  final String title;
  final DateTime start;
  DateTime latestPause;
  DateTime end;
  int pauses;
  Duration pauseTime;
  bool isRunning;
  bool isPaused;
  final List<String> categories;
  final List<String> labels;
  final String superProjectName;

  Task({
    @required this.id,
    @required this.title,
    @required this.start,
    this.latestPause,
    this.end,
    this.pauses = 0,
    this.pauseTime = Duration.zero,
    this.isRunning = true,
    this.isPaused = false,
    @required this.categories,
    @required this.labels,
    @required this.superProjectName,
  });

  Duration getRunningTime() {
    if (end != null) {
      return end.difference(start) - pauseTime;
    } else if (isPaused) {
      return latestPause.difference(start) - pauseTime;
    } else {
      return (DateTime.now().difference(start) - pauseTime);
    }
  }

  String getRunningTimeString() {
    Duration runTime = getRunningTime();
    String h, m;
    int time = runTime.inMinutes;
    int hrs = (time / 60).floor();
    int mins = time % 60;
    (hrs / 10).floor() == 0
        ? h = '0' + hrs.toString() + ':'
        : h = hrs.toString() + ':';
    (mins / 10).floor() == 0 ? m = '0' + mins.toString() : m = mins.toString();
    return (h + m);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/tasks.csv');
  }

  Future<List<Task>> get tasks async {
    File csvFile = await _localFile;
    String csvString = csvFile.readAsStringSync();
    print('Tasks getter called');
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
        categories: row[9].split(" "),
        labels: row[10].split(" "),
        superProjectName: row[11],
      );
    }).toList();
    print(rows[0].title);
    return rows;
  }

  void writeCsv(List<Task> tasks) {
    // print('Writing to CSV');
    final rows = ListToCsvConverter().convert(tasks
        .map((t) => [
              t.id,
              t.title,
              DateFormat("dd-MM-yyyy HH:mm:ss").format(t.start),
              t.latestPause != null
                  ? DateFormat("dd-MM-yyyy HH:mm:ss").format(t.latestPause)
                  : "",
              t.end != null
                  ? DateFormat("dd-MM-yyyy HH:mm:ss").format(t.end)
                  : "",
              t.pauses,
              t.pauseTime.inSeconds,
              t.isRunning ? 1 : 0,
              t.isPaused ? 1 : 0,
              t.categories.join(" "),
              t.labels.join(" "),
              t.superProjectName == null ? "" : t.superProjectName
            ])
        .toList());
    _localFile.then((file) {
      file.writeAsStringSync(
        rows,
        mode: FileMode.writeOnly,
      );
      // print(rows);
    });

    notifyListeners();
  }

  Future<int> get getIndex async {
    print('Get Index called');
    var t = await tasks;
    print('Length: ${t.length}');
    return t.indexWhere((t) => t.id == id);
  }

  void resume() {
    print('resumed');
    getIndex.then((index) {
      tasks.then((taskList) {
        taskList[index].isRunning = true;
        taskList[index].isPaused = false;
        taskList[index].pauseTime +=
            DateTime.now().difference(taskList[index].latestPause);
        writeCsv(taskList);
        notifyListeners();
      });
    });
  }

  void pause() {
    print('paused');
    getIndex.then((index) {
      print(index);
      tasks.then((taskList) {
        taskList[index].isRunning = false;
        taskList[index].isPaused = true;
        taskList[index].pauses++;
        taskList[index].latestPause = DateTime.now();
        writeCsv(taskList);
        notifyListeners();
      });
    });
  }

  void complete() async {
    final index = await getIndex;
    var taskList = await tasks;
    taskList[index].isRunning = false;
    taskList[index].isPaused = true;
    taskList[index].end = DateTime.now();
    taskList[index].latestPause = DateTime.now();
    writeCsv(taskList);
    notifyListeners();
  }
}
