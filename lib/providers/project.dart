import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'task.dart';

enum PaymentMode { Fixed, Rate, None }

class Project with ChangeNotifier {
  BuildContext context;

  SyncStatus syncStatus;
  String id;
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

  Project(
    this.context, {
    this.syncStatus = SyncStatus.NewTask,
    @required this.id,
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
  });

  Future<bool> get _isConnected async {
    try {
      final result =
          await InternetAddress.lookup('taskflow1-4a77f.firebaseio.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<String> get _localPath async {
    // gets the AppData directory
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    // gets the st_projectid.csv file from the AppData directory
    final path = await _localPath;
    return File('$path/st_${id.replaceAll(new RegExp(r'[:. \-]'), "")}.csv');
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
              t.syncStatus.index,
            ])
        .toList());
    File f = await _localFile;
    await f.writeAsString(rows, mode: FileMode.writeOnly);
    notifyListeners();
  }

  DateFormat parser = DateFormat("dd-MM-yyyy HH:mm:ss");

  Future<void> loadData() async {
    // function to load the data from the tasks.csv file into Task
    // models which are then put into the subTasks list

    String csvPath = await _localPath;
    String csvString = await File(
            '$csvPath/st_${id.replaceAll(new RegExp(r'[:. \-]'), "")}.csv')
        .readAsString();

    // String csvString = await rootBundle.loadString('assets/data/tasks.csv');
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(csvString);

    subTasks = [];
    rowsAsListOfValues.forEach((row) {
      subTasks.add(Task(
        id: row[0],
        title: row[1].toString(),
        start: parser.parse(row[2]),
        latestPause: row[3].isNotEmpty ? parser.parse(row[3]) : null,
        end: row[4].isNotEmpty ? parser.parse(row[4]) : null,
        pauses: row[5],
        pauseTime: Duration(seconds: row[6]),
        isRunning: row[7] == 1,
        isPaused: row[8] == 1,
        syncStatus: SyncStatus.values[row[9]],
      ));
    });
    notifyListeners();
  }

  Future<void> addSubTask({
    BuildContext ctx,
    String id,
    DateTime start,
    String title,
  }) async {
    var response;
    final firebaseUser = context.read<User>();

    if (await _isConnected && firebaseUser != null) {
      String userId = firebaseUser.uid;
      String token = (await firebaseUser.getIdTokenResult()).token;
      final url =
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/projects/${this.id}/subtasks.json?auth=$token";
      response = await http.post(
        url,
        body: json.encode(
          {
            'title': title,
            'start': DateFormat("dd-MM-yyyy HH:mm:ss").format(start),
            'isRunning': true,
            'isPaused': false,
          },
        ),
      );
    }

    Task newTask = Task(
      syncStatus: (firebaseUser != null)
          ? (await _isConnected ? SyncStatus.FullySynced : SyncStatus.NewTask)
          : SyncStatus.FullySynced,
      start: start,
      title: title,
      isRunning: true,
      isPaused: false,
      id: response != null ? json.decode(response.body)["name"] : id,
    );

    subTasks.add(newTask);
    await writeCsv(subTasks);
    notifyListeners();
  }

  String cardTags({bool requireLabels: true}) {
    if (paymentMode != PaymentMode.None) {
      return 'Paid, ' +
          category +
          (requireLabels ? (', ' + labels.join(', ')) : '');
    }
    return category + ', ' + labels.join(', ');
  }

  DateTime get lastActive {
    DateTime last = subTasks.isNotEmpty ? subTasks.first.latestPause : start;

    subTasks.forEach((subTask) {
      if (subTask.latestPause.isAfter(last)) last = subTask.latestPause;
    });
    return last;
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

  double get earningsAsNum {
    if (paymentMode == PaymentMode.None) {
      return 0;
    } else if (paymentMode == PaymentMode.Fixed) {
      return rate;
    } else {
      return (rate * workingDuration.inHours);
    }
  }

  Future<void> resume(int index) async {
    // Arguments => index: The index of the task to be resumed
    // Resumes the task at 'index' in the subTasks list

    subTasks[index].isRunning = true;
    subTasks[index].isPaused = false;
    subTasks[index].pauseTime +=
        DateTime.now().difference(subTasks[index].latestPause);

    final firebaseUser = context.read<User>();
    if (await _isConnected && firebaseUser != null) {
      String userId = firebaseUser.uid;
      String token = (await firebaseUser.getIdTokenResult()).token;
      final url =
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/projects/$id/subtasks/${subTasks[index].id}.json?auth=$token";
      var res = await http.patch(
        url,
        body: json.encode(
          {
            'isRunning': true,
            'isPaused': false,
            'pauseTime': subTasks[index].pauseTime.inSeconds,
          },
        ),
      );
    }

    subTasks[index].syncStatus = (firebaseUser != null)
        ? (await _isConnected
            ? (subTasks[index].syncStatus == SyncStatus.UpdatedTask
                ? SyncStatus.FullySynced
                : subTasks[index].syncStatus)
            : (subTasks[index].syncStatus != SyncStatus.NewTask
                ? SyncStatus.UpdatedTask
                : SyncStatus.NewTask))
        : SyncStatus.FullySynced;
    await writeCsv(subTasks);
    notifyListeners();
  }

  Future<void> pause(int index) async {
    // Arguments => index: The index of the task to be resumed
    // Resumes the task at 'index' in the subTasks list
    subTasks[index].isRunning = false;
    subTasks[index].isPaused = true;
    subTasks[index].pauses++;
    subTasks[index].latestPause = DateTime.now();
    final firebaseUser = context.read<User>();
    if (await _isConnected && await firebaseUser != null) {
      String userId = firebaseUser.uid;
      String token = (await firebaseUser.getIdTokenResult()).token;
      final url =
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/projects/$id/subtasks/${subTasks[index].id}.json?auth=$token";
      var res = await http.patch(
        url,
        body: json.encode(
          {
            'isRunning': false,
            'isPaused': true,
            'pauses': subTasks[index].pauses,
            'latestPause': DateFormat("dd-MM-yyyy HH:mm:ss")
                .format(subTasks[index].latestPause),
          },
        ),
      );
    }
    subTasks[index].syncStatus = (firebaseUser != null)
        ? (await _isConnected
            ? (subTasks[index].syncStatus == SyncStatus.UpdatedTask
                ? SyncStatus.FullySynced
                : subTasks[index].syncStatus)
            : (subTasks[index].syncStatus != SyncStatus.NewTask
                ? SyncStatus.UpdatedTask
                : SyncStatus.NewTask))
        : SyncStatus.FullySynced;
    await writeCsv(subTasks);
    notifyListeners();
  }

  Future<void> complete(int index) async {
    subTasks[index].isRunning = false;
    subTasks[index].isPaused = true;
    subTasks[index].end = DateTime.now();
    subTasks[index].latestPause = subTasks[index].end;

    final firebaseUser = context.read<User>();
    if (await _isConnected && firebaseUser != null) {
      String userId = firebaseUser.uid;
      String token = (await firebaseUser.getIdTokenResult()).token;
      final url =
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/projects/$id/subtasks/${subTasks[index].id}.json?auth=$token";
      final res = await http.patch(
        url,
        body: json.encode(
          {
            'isRunning': subTasks[index].isRunning,
            'isPaused': subTasks[index].isPaused,
            'latestPause': DateFormat("dd-MM-yyyy HH:mm:ss")
                .format(subTasks[index].latestPause),
            'end':
                DateFormat("dd-MM-yyyy HH:mm:ss").format(subTasks[index].end),
          },
        ),
      );
    }

    subTasks[index].syncStatus = (firebaseUser != null)
        ? (await _isConnected
            ? (subTasks[index].syncStatus == SyncStatus.UpdatedTask
                ? SyncStatus.FullySynced
                : subTasks[index].syncStatus)
            : (subTasks[index].syncStatus != SyncStatus.NewTask
                ? SyncStatus.UpdatedTask
                : SyncStatus.NewTask))
        : SyncStatus.FullySynced;

    await writeCsv(subTasks);
    notifyListeners();
  }

  Future<void> pullFromFireBase() async {
    if (await _isConnected) {
      Map<String, dynamic> syncedTasks;
      final firebaseUser = context.read<User>();
      if (firebaseUser != null) {
        String userId = firebaseUser.uid;
        String token = (await firebaseUser.getIdTokenResult()).token;
        final url =
            "https://taskflow1-4a77f.firebaseio.com/Users/$userId/projects/$id/subtasks.json?auth=$token";
        final res = await http.get(url);
        syncedTasks = json.decode(res.body);
      }
      subTasks = [];
      if (subTasks != null) {
        subTasks.clear();
      }
      if (syncedTasks != null) {
        syncedTasks.forEach(
          (id, data) {
            subTasks.add(
              Task(
                id: id,
                title: data['title'],
                start: parser.parse(data['start']),
                isRunning: data['isRunning'],
                isPaused: data['isPaused'],
                latestPause: data.containsKey('latestPause')
                    ? parser.parse(data['latestPause'])
                    : null,
                pauses: data.containsKey('pauses') ? data['pauses'] : 0,
                pauseTime: data.containsKey('pauseTime')
                    ? Duration(seconds: data['pauseTime'])
                    : Duration.zero,
                end: data.containsKey('end') ? parser.parse(data['end']) : null,
                syncStatus: SyncStatus.FullySynced,
              ),
            );
          },
        );
        await writeCsv(subTasks);
      }
    }
  }

  Future<void> syncEngine() async {
    if (await _isConnected) {
      final firebaseUser = context.read<User>();
      await loadData();
      if (subTasks != null && firebaseUser != null) {
        String userId = firebaseUser.uid;
        String token = (await firebaseUser.getIdTokenResult()).token;
        print("Token $token");
        for (int i = 0; i < subTasks.length; i++) {
          Task task = subTasks[i];
          if (task.syncStatus == SyncStatus.UpdatedTask) {
            final url =
                "https://taskflow1-4a77f.firebaseio.com/Users/$userId/projects/$id/subtasks/${task.id}.json?auth=$token";
            await http.patch(
              url,
              body: json.encode(
                {
                  'isRunning': task.isRunning,
                  'isPaused': task.isPaused,
                  'latestPause': DateFormat("dd-MM-yyyy HH:mm:ss")
                      .format(task.latestPause),
                  'end': task.end != null
                      ? DateFormat("dd-MM-yyyy HH:mm:ss").format(task.end)
                      : null,
                },
              ),
            );
          } else if (task.syncStatus == SyncStatus.NewTask) {
            final url =
                "https://taskflow1-4a77f.firebaseio.com/Users/$userId/projects/$id/subtasks.json?auth=$token";
            final res = await http.post(
              url,
              body: json.encode(
                {
                  'title': task.title,
                  'start': DateFormat("dd-MM-yyyy HH:mm:ss").format(task.start),
                  'latestPause': task.latestPause != null
                      ? DateFormat("dd-MM-yyyy HH:mm:ss")
                          .format(task.latestPause)
                      : null,
                  'end': task.end != null
                      ? DateFormat("dd-MM-yyyy HH:mm:ss").format(task.end)
                      : null,
                  'pauses': task.pauses,
                  'pauseTime':
                      task.pauseTime != null ? task.pauseTime.inSeconds : null,
                  'isRunning': task.isRunning,
                  'isPaused': task.isPaused,
                },
              ),
            );
            print(json.decode(res.body));
            subTasks[i].id = json.decode(res.body)['name'];
          }
          subTasks[i].syncStatus = SyncStatus.FullySynced;
        }
        await writeCsv(subTasks);
      }
    }
  }

  Future<void> purgeSubTasks() async {
    File subTaskFile = await _localFile;
    await subTaskFile.delete();
  }
}
