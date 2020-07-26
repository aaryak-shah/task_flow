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
  final String category;
  List<String> labels;
  final String superProjectName;
  final Duration goalTime;

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
    @required this.category,
    @required this.labels,
    @required this.superProjectName,
    this.goalTime = Duration.zero,
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

  String getTimeString(String mode) {
    Duration getTime = mode == 'run' ? getRunningTime() : mode == 'goal' ? goalTime : Duration.zero;
    String h, m;
    int time = getTime.inMinutes;
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
        superProjectName: row[11],
        goalTime: Duration(seconds: row[12]),
      );
    }).toList();
    return rows;
  }

  Future<int> get getIndex async {
    var t = await tasks;
    return t.indexWhere((t) => t.id == id);
  }
}
