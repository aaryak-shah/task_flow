import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'task.dart';

enum PaymentMode { Fixed, Rate, None }

class Project with ChangeNotifier {
  final String id;
  final String name;
  final DateTime start;
  DateTime end;
  DateTime deadline;
  final String category;
  List<String> labels = [];
  List<Task> subTasks = [];
  PaymentMode paymentMode = PaymentMode.None;
  double rate = 0;
  String client = '';
  DateTime lastActive;

  Project(
      {@required this.id,
      @required this.name,
      @required this.start,
      this.end,
      @required this.deadline,
      @required this.category,
      this.labels,
      this.subTasks,
      this.paymentMode,
      this.rate,
      this.client,
      this.lastActive});

  Future<String> get _localPath async {
    // gets the AppData directory
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    // gets the subtasks.csv file from the AppData directory
    final path = await _localPath;
    return File('$path/subtasks.csv');
  }

  Duration get totalPauseTime {
    Duration total = Duration.zero;
    total = subTasks.fold(total, (total, element) {
      return total + element.pauseTime;
    });
    return total;
  }

  int get totalPauses {
    int total = 0;
    total = subTasks.fold(total, (total, element) {
      return total + element.pauses;
    });
    return total;
  }

  Future<void> writeCsv(List<Task> tasks) async {
    // Arguments => tasks: a list of Task objects to be written to the tasks.csv file
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
              t.category,
              t.labels.isNotEmpty ? t.labels.join("|") : "",
              t.superProjectId == null ? "" : t.superProjectId,
            ])
        .toList());
    File f = await _localFile;
    await f.writeAsString(rows, mode: FileMode.writeOnly);
    notifyListeners();
  }

  DateFormat parser = DateFormat("dd-MM-yyyy HH:mm:ss");

  Future<void> loadData() async {
    // function to load the data from the tasks.csv file into Task
    // models which are then put into the _tasks list

    String csvPath = await _localPath;
    String csvString = await File('$csvPath/subtasks.csv').readAsString();
    // String csvString = await rootBundle.loadString('assets/data/tasks.csv');
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(csvString);

    rowsAsListOfValues.forEach((row) {
      if (id == row[11]) {
        subTasks.add(Task(
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
          labels: row[10] != "" ? row[10].split("|") : [],
          superProjectId: row[11],
        ));
      }
    });
    notifyListeners();
  }

  Future<void> addSubTask({
    DateTime start,
    String title,
  }) async {
    Task newTask = Task(
      start: start,
      title: title,
      superProjectId: this.id,
      isRunning: true,
      isPaused: false,
      id: DateTime.now().toString(),
      labels: labels,
      category: category,
    );

    subTasks.add(newTask);
    await writeCsv(subTasks);
  }

  String cardTags({bool requireLabels: true}) {
    if (paymentMode != PaymentMode.None) {
      return 'Paid, ' +
          category +
          (requireLabels ? (', ' + labels.join(', ')) : '');
    }
    return category + ', ' + labels.join(', ');
  }

  Duration get elapsedDuration {
    return lastActive.difference(start);
  }

  Duration get workingDuration {
    Duration runningTime = Duration.zero;
    runningTime = subTasks != null
        ? subTasks.fold(
            runningTime, (runningTime, st) => runningTime + st.getRunningTime())
        : Duration.zero;

    return runningTime;
  }

  String get deadlineString {
    return DateTime.now().difference(start).inDays.toString() +
        'd / ' +
        deadline.difference(start).inDays.toString() +
        'd';
  }

  String get earnings {
    if (paymentMode == PaymentMode.None) {
      return '-';
    } else if (paymentMode == PaymentMode.Fixed) {
      return '₹' + rate.toStringAsFixed(2);
    } else {
      return '₹' + (rate * workingDuration.inHours).toStringAsFixed(2);
    }
  }

  Future<void> resume(int index) async {
    // Arguments => index: The index of the task to be resumed
    // Resumes the task at 'index' in the _tasks list

    subTasks[index].isRunning = true;
    subTasks[index].isPaused = false;
    subTasks[index].pauseTime +=
        DateTime.now().difference(subTasks[index].latestPause);

    await writeCsv(subTasks);
    notifyListeners();
  }

  Future<void> pause(int index) async {
    // Arguments => index: The index of the task to be resumed
    // Resumes the task at 'index' in the _tasks list

    print('subtask pause');
    subTasks[index].isRunning = false;
    subTasks[index].isPaused = true;
    subTasks[index].pauses++;
    subTasks[index].latestPause = DateTime.now();

    await writeCsv(subTasks);
    notifyListeners();
  }
}
