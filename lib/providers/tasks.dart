import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class Tasks with ChangeNotifier {
  // variable that stores list of tasks
  BuildContext context;
  List<Task> _tasks = [];
  Tasks(this.context);
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
      final result =
          await InternetAddress.lookup('taskflow1-4a77f.firebaseio.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  DateFormat parser = DateFormat("dd-MM-yyyy HH:mm:ss");

  Future<void> loadData() async {
    // function to load the data from the tasks.csv file into Task
    // models which are then put into the _tasks list

    final String csvPath = await _localPath;

    final String csvString = await File('$csvPath/tasks.csv').readAsString();

    // String csvString = await rootBundle.loadString('assets/data/tasks.csv');
    final List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(csvString);

    _tasks = rowsAsListOfValues.map((row) {
      return Task(
        id: row[0] as String,
        title: row[1].toString(),
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
        labels: (row[10] as String) != "" ? (row[10] as String).split("|") : [],
        goalTime: Duration(seconds: row[11] as int),
        syncStatus: SyncStatus.values[row[12] as int],
      );
    }).toList();
    notifyListeners();
  }

  // DEBUG FUNCTION
  // Future<List<List<dynamic>>> readLocalData() async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   String csvString = await File('${directory.path}/tasks.csv').readAsString();
  //   List<List<dynamic>> rowsAsListOfValues =
  //       const CsvToListConverter().convert(csvString);
  //   return (rowsAsListOfValues);
  // }

  Future<void> purgeOldTasks() async {
    // function to delete (purge) tasks which have a latest pause date
    // older than 1 week so as to save space and computation time

    await loadData();
    _tasks.removeWhere((task) {
      return task.latestPause != null &&
          task.latestPause!.isBefore(
            DateTime.now().subtract(
              const Duration(
                days: 7,
              ),
            ),
          );
    });
    await writeCsv(_tasks);
    notifyListeners();
  }

  List<Task> get tasks {
    // tasks getter, gives a copy of _tasks
    final t = [..._tasks];
    return t;
  }

  List<Task> get recentTasks {
    // gets a list of paused tasks whose latest pause is within the past 7 days
    final recent = tasks.where((t) {
      return t.goalTime == Duration.zero &&
          t.isPaused &&
          t.latestPause!.isAfter(DateTime.now().subtract(const Duration(days: 7)));
    }).toList();
    return recent;
  }

  List<Map<String, Object>> get weekTasks {
    // function that groups up the tasks according to their day of latest pause
    // returns a list of maps containing the day of the week (0,1,... 6) as the key
    // and the total time spent working on tasks on that day as the value

    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(Duration(days: index));
      Duration total = const Duration();

      for (int i = 0; i < recentTasks.length; i++) {
        if (recentTasks[i].latestPause!.day == weekDay.day &&
            recentTasks[i].latestPause!.month == weekDay.month &&
            recentTasks[i].latestPause!.year == weekDay.year) {
          total += recentTasks[i].getRunningTime();
        }
      }

      return {'day': index, 'time': total};
    }).reversed.toList();
  }

  Duration get totalTime {
    // getter to calculate the total cumulative time spent working on tasks in the past week
    return weekTasks.fold(const Duration(),
        (previousSum, day) => previousSum + (day['time']! as Duration));
  }

  String categoryString(String cid) {
    // Arguments => cid: String id of the task whose category is needed
    // Returns => category of the task with id as cid

    return _tasks[_tasks.indexWhere((tsk) => cid == tsk.id)].category;
  }

  Future<void> writeCsv(List<Task> tasks) async {
    // Arguments => tasks: a list of Task objects to be written to the tasks.csv file
    final rows = const ListToCsvConverter().convert(tasks
        .map((t) => [
              t.id,
              t.title,
              DateFormat("dd-MM-yyyy HH:mm:ss").format(t.start),
              if (t.latestPause != null)
                DateFormat("dd-MM-yyyy HH:mm:ss").format(t.latestPause!)
              else
                "",
              if (t.end != null)
                DateFormat("dd-MM-yyyy HH:mm:ss").format(t.end!)
              else
                "",
              t.pauses,
              t.pauseTime.inSeconds,
              if (t.isRunning) 1 else 0,
              if (t.isPaused) 1 else 0,
              t.category,
              if (t.labels != null) t.labels!.join("|") else "",
              t.goalTime.inSeconds,
              t.syncStatus.index
            ])
        .toList());
    final File f = await _localFile;
    await f.writeAsString(rows, mode: FileMode.writeOnly);
    notifyListeners();
  }

  Future<void> addTask(
    final String id,
    final String title,
    final DateTime start,
    final String category,
    final List<String> labels,
  ) async {
    // Arguments => id: The id of the task to be added,
    //              title: Title of the task to be added,
    //              start: DateTime object of the start of the task to be added,
    //              category: Category of the task to be added,
    //              labels: List of labels of the task to be added,
    //
    // Adds the Task object with the above arguments to the _tasks list
    // and also to the tasks.csv file

    http.Response? response;
    final firebaseUser = context.read<User?>();

    if (await _isConnected && firebaseUser != null) {
      final userId = firebaseUser.uid;
      final String? token = (await firebaseUser.getIdTokenResult()).token;
      final Uri url = Uri.parse(
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/tasks.json?auth=$token");
      response = await http.post(
        url,
        body: json.encode(
          {
            'title': title,
            'start': DateFormat("dd-MM-yyyy HH:mm:ss").format(start),
            'category': category,
            'isRunning': true,
            'isPaused': false,
          },
        ),
      );
    }

    final task = Task(
        id: response != null
            ? json.decode(response.body)['name'] as String
            : id,
        title: title,
        start: start,
        category: category,
        labels: labels,
        syncStatus: (firebaseUser != null)
            ? (await _isConnected ? SyncStatus.fullySynced : SyncStatus.newTask)
            : SyncStatus.fullySynced);
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
          0,
          task.syncStatus.index
        ],
      ],
    );
    final File f = await _localFile;
    await f.writeAsString(row, mode: FileMode.append, flush: true);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> addLabels(
    final int index,
    final List<String> selected,
    final List<String> labels,
  ) async {
    // Arguments => index: The index of the task in the list to which the labels are to be added,
    //              selected: The list of labels to be added to the Task,
    //              labels: The list of available labels (shown as chips),
    //
    // Adds 'selected' labels to the task at 'index' in the _tasks list
    // Also updates the 'AvailableLabels' key in SharedPreferences

    _tasks[index].labels?.addAll(selected);
    _tasks[index].labels = _tasks[index].labels?.toSet().toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('AvailableLabels', labels);
    final firebaseUser = context.read<User?>();

    if (await _isConnected && firebaseUser != null) {
      final userId = firebaseUser.uid;
      final String? token = (await firebaseUser.getIdTokenResult()).token;
      final Uri url = Uri.parse(
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/tasks/${_tasks[index].id}.json?auth=$token");
      await http.patch(
        url,
        body: json.encode(
          {
            'labels': _tasks[index].labels?.join('|'),
          },
        ),
      );
    }

    _tasks[index].syncStatus = (firebaseUser != null)
        ? (await _isConnected
            ? (_tasks[index].syncStatus == SyncStatus.updatedTask
                ? SyncStatus.fullySynced
                : _tasks[index].syncStatus)
            : (_tasks[index].syncStatus != SyncStatus.newTask
                ? SyncStatus.updatedTask
                : SyncStatus.newTask))
        : SyncStatus.fullySynced;
    await writeCsv(_tasks);
    notifyListeners();
  }

  Future<List<String>> get availableLabels async {
    // getter to fetch the list of available labels from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('AvailableLabels') ?? [];
  }

  Future<void> resume(int index) async {
    // Arguments => index: The index of the task to be resumed
    // Resumes the task at 'index' in the _tasks list

    _tasks[index].isRunning = true;
    _tasks[index].isPaused = false;
    _tasks[index].pauseTime +=
        DateTime.now().difference(_tasks[index].latestPause!);
    final firebaseUser = context.read<User?>();

    if (await _isConnected && firebaseUser != null) {
      final userId = firebaseUser.uid;
      final String? token = (await firebaseUser.getIdTokenResult()).token;
      final Uri url = Uri.parse(
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/tasks/${_tasks[index].id}.json?auth=$token");
      await http.patch(
        url,
        body: json.encode(
          {
            'isRunning': true,
            'isPaused': false,
            'pauseTime': _tasks[index].pauseTime.inSeconds,
          },
        ),
      );
    }

    _tasks[index].syncStatus = (firebaseUser != null)
        ? (await _isConnected
            ? (_tasks[index].syncStatus == SyncStatus.updatedTask
                ? SyncStatus.fullySynced
                : _tasks[index].syncStatus)
            : (_tasks[index].syncStatus != SyncStatus.newTask
                ? SyncStatus.updatedTask
                : SyncStatus.newTask))
        : SyncStatus.fullySynced;
    await writeCsv(_tasks);
    notifyListeners();
  }

  Future<void> pause(int index) async {
    // Arguments => index: The index of the task to be paused
    // Pauses the task at 'index' in the _tasks list
    _tasks[index].isRunning = false;
    _tasks[index].isPaused = true;
    _tasks[index].pauses++;
    _tasks[index].latestPause = DateTime.now();
    final firebaseUser = context.read<User?>();

    if (await _isConnected && firebaseUser != null) {
      final userId = firebaseUser.uid;
      final String? token = (await firebaseUser.getIdTokenResult()).token;
      final Uri url = Uri.parse(
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/tasks/${_tasks[index].id}.json?auth=$token");
      await http.patch(
        url,
        body: json.encode(
          {
            'isRunning': false,
            'isPaused': true,
            'pauses': _tasks[index].pauses,
            'latestPause': DateFormat("dd-MM-yyyy HH:mm:ss")
                .format(_tasks[index].latestPause!),
            'labels': _tasks[index].labels == null
                ? null
                : _tasks[index].labels!.join("|")
          },
        ),
      );
    }

    _tasks[index].syncStatus = (firebaseUser != null)
        ? (await _isConnected
            ? (_tasks[index].syncStatus == SyncStatus.updatedTask
                ? SyncStatus.fullySynced
                : _tasks[index].syncStatus)
            : (_tasks[index].syncStatus != SyncStatus.newTask
                ? SyncStatus.updatedTask
                : SyncStatus.newTask))
        : SyncStatus.fullySynced;
    await writeCsv(_tasks);
    notifyListeners();
  }

  Future<void> suspend(int index) async {
    // Arguments => index: The index of the task to be suspended
    // Suspends (i.e. Pauses without incrementing the no. of pauses)
    // the task at 'index' in the _tasks list

    _tasks[index].isRunning = false;
    _tasks[index].isPaused = true;
    _tasks[index].latestPause = DateTime.now();
    await writeCsv(_tasks);
    notifyListeners();
  }

  Future<void> unSuspend(int index) async {
    // Arguments => index: The index of the task to be unsuspended
    // Brings the task at 'index' in the _tasks list out of suspension
    // (i.e. Resumes the task without updating the pause time)
    _tasks[index].isRunning = true;
    _tasks[index].isPaused = false;
    await writeCsv(_tasks);
    notifyListeners();
  }

  Future<void> complete(int index) async {
    // Arguments => index: The index of the task to be marked as complete
    // Ends the task at 'index' in the _tasks list

    _tasks[index].isRunning = false;
    _tasks[index].isPaused = true;
    _tasks[index].end = DateTime.now();
    _tasks[index].latestPause = _tasks[index].end;

    final firebaseUser = context.read<User?>();
    if (await _isConnected && firebaseUser != null) {
      final userId = firebaseUser.uid;
      final String? token = (await firebaseUser.getIdTokenResult()).token;
      final Uri url = Uri.parse(
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/tasks/${_tasks[index].id}.json?auth=$token");
      await http.patch(
        url,
        body: json.encode(
          {
            'isRunning': _tasks[index].isRunning,
            'isPaused': _tasks[index].isPaused,
            'labels': _tasks[index].labels == null
                ? null
                : _tasks[index].labels!.join("|"),
            'latestPause': DateFormat("dd-MM-yyyy HH:mm:ss")
                .format(_tasks[index].latestPause!),
            'end': DateFormat("dd-MM-yyyy HH:mm:ss").format(_tasks[index].end!),
          },
        ),
      );
    }

    _tasks[index].syncStatus = (firebaseUser != null)
        ? (await _isConnected
            ? (_tasks[index].syncStatus == SyncStatus.updatedTask
                ? SyncStatus.fullySynced
                : _tasks[index].syncStatus)
            : (_tasks[index].syncStatus != SyncStatus.newTask
                ? SyncStatus.updatedTask
                : SyncStatus.newTask))
        : SyncStatus.fullySynced;
    await writeCsv(_tasks);
    notifyListeners();
  }

  Future<void> pullFromFireBase() async {
    if (await _isConnected) {
      Map<String, dynamic>? syncedTasks;
      final firebaseUser = context.read<User?>();

      if (firebaseUser != null) {
        final userId = firebaseUser.uid;
        final String? token = (await firebaseUser.getIdTokenResult()).token;
        final Uri url = Uri.parse(
            "https://taskflow1-4a77f.firebaseio.com/Users/$userId/tasks.json?auth=$token");
        final res = await http.get(url);
        syncedTasks = json.decode(res.body) as Map<String, dynamic>?;
      }

      _tasks.clear();

      if (syncedTasks != null) {
        syncedTasks.forEach((id, data) {
          _tasks.add(
            Task(
              id: id,
              title: data['title'] as String,
              start: parser.parse(data['start'] as String),
              category: data['category'] as String,
              isRunning: data['isRunning'] as bool,
              isPaused: data['isPaused'] as bool,
              latestPause:
                  (data as Map<String, dynamic>).containsKey('latestPause')
                      ? parser.parse(data['latestPause'] as String)
                      : null,
              labels: data.containsKey('labels')
                  ? (data['labels'] as String).split('|')
                  : [],
              goalTime: data.containsKey('goalTime')
                  ? Duration(seconds: data['goalTime'] as int)
                  : Duration.zero,
              pauses: data.containsKey('pauses') ? data['pauses'] as int : 0,
              pauseTime: data.containsKey('pauseTime')
                  ? Duration(seconds: data['pauseTime'] as int)
                  : Duration.zero,
              end: data.containsKey('end')
                  ? parser.parse(data['end'] as String)
                  : null,
              syncStatus: SyncStatus.fullySynced,
            ),
          );
        });
        await writeCsv(_tasks);
      }
    }
  }

  Future<void> syncEngine() async {
    final firebaseUser = context.read<User?>();

    await loadData();
    if (firebaseUser != null) {
      final userId = firebaseUser.uid;
      final String? token = (await firebaseUser.getIdTokenResult()).token;
      for (int i = 0; i < _tasks.length; i++) {
        final Task task = _tasks[i];
        if (await _isConnected) {
          if (task.syncStatus == SyncStatus.updatedTask) {
            final Uri url = Uri.parse(
                "https://taskflow1-4a77f.firebaseio.com/Users/$userId/tasks/${task.id}.json?auth=$token");
            await http.patch(
              url,
              body: json.encode(
                {
                  'isRunning': task.isRunning,
                  'isPaused': task.isPaused,
                  'labels': task.labels != null ? task.labels!.join("|") : null,
                  'latestPause': task.latestPause != null
                      ? DateFormat("dd-MM-yyyy HH:mm:ss")
                          .format(task.latestPause!)
                      : null,
                  'end': task.end != null
                      ? DateFormat("dd-MM-yyyy HH:mm:ss").format(task.end!)
                      : null,
                },
              ),
            );
          } else if (task.syncStatus == SyncStatus.newTask) {
            final Uri url = Uri.parse(
                "https://taskflow1-4a77f.firebaseio.com/Users/$userId/tasks.json?auth=$token");
            final res = await http.post(
              url,
              body: json.encode(
                {
                  'title': task.title,
                  'start': DateFormat("dd-MM-yyyy HH:mm:ss").format(task.start),
                  'latestPause': task.latestPause != null
                      ? DateFormat("dd-MM-yyyy HH:mm:ss")
                          .format(task.latestPause!)
                      : null,
                  'end': task.end != null
                      ? DateFormat("dd-MM-yyyy HH:mm:ss").format(task.end!)
                      : null,
                  'labels': task.labels != null ? task.labels!.join("|") : null,
                  'goalTime': task.goalTime.inSeconds,
                  'pauses': task.pauses,
                  'pauseTime': task.pauseTime.inSeconds,
                  'isRunning': task.isRunning,
                  'isPaused': task.isPaused,
                  'category': task.category,
                },
              ),
            );
            _tasks[i].id = json.decode(res.body)['name'] as String;
          }
          _tasks[i].syncStatus = SyncStatus.fullySynced;
        }
      }

      await writeCsv(_tasks);
    }
  }
}
