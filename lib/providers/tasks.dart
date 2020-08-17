import 'dart:io';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './task.dart';
import 'auth.dart';

class Tasks with ChangeNotifier {
  // variable that stores list of tasks
  BuildContext context;
  List<Task> _tasks;
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
  }

  DateFormat parser = DateFormat("dd-MM-yyyy HH:mm:ss");

  Future<void> loadData() async {
    // function to load the data from the tasks.csv file into Task
    // models which are then put into the _tasks list

    String csvPath = await _localPath;
    String csvString = await File('$csvPath/tasks.csv').readAsString();
    // String csvString = await rootBundle.loadString('assets/data/tasks.csv');
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(csvString);

    _tasks = rowsAsListOfValues.map((row) {
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
        labels: row[10] != "" ? row[10].split("|") : [],
        superProjectId: row[11],
        goalTime: Duration(seconds: row[12]),
        syncStatus: SyncStatus.values[row[13]],
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
          task.latestPause.isBefore(
            DateTime.now().subtract(
              Duration(
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
    final t = _tasks == null ? null : [..._tasks];
    return t;
  }

  List<Task> get recentTasks {
    // gets a list of paused tasks whose latest pause is within the past 7 days
    final recent = tasks.where((t) {
      return t.goalTime == Duration.zero &&
          t.isPaused &&
          t.latestPause.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
    return recent;
  }

  List<Map<String, Object>> get weekTasks {
    // function that groups up the tasks according to their day of latest pause
    // returns a list of maps containing the day of the week (0,1,... 6) as the key
    // and the total time spent working on tasks on that day as the value

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
    // getter to calculate the total cumulative time spent working on tasks in the past week
    return weekTasks.fold(
        Duration(), (previousSum, day) => previousSum + day['time']);
  }

  String categoryString(String cid) {
    // Arguments => cid: String id of the task whose category is needed
    // Returns => category of the task with id as cid

    return _tasks[_tasks.indexWhere((tsk) => cid == tsk.id)].category;
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
              t.goalTime.inSeconds,
              t.syncStatus.index
            ])
        .toList());
    File f = await _localFile;
    await f.writeAsString(rows, mode: FileMode.writeOnly);
    notifyListeners();
  }

  Future<void> addTask(
    final String id,
    final String title,
    final DateTime start,
    final String category,
    final List<String> labels,
    final String superProjectName,
  ) async {
    // Arguments => id: The id of the task to be added,
    //              title: Title of the task to be added,
    //              start: DateTime object of the start of the task to be added,
    //              category: Category of the task to be added,
    //              labels: List of labels of the task to be added,
    //              superProjectName: Name of the project the task to be added is under
    //
    // Adds the Task object with the above arguments to the _tasks list
    // and also to the tasks.csv file

    var response;
    var authData = Provider.of<Auth>(context, listen: false);
    if (await _isConnected && await authData.isAuth) {
      String userId = await authData.userId;
      String token = authData.token.token;
      final url =
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/tasks.json?auth=$token";
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
        id: response != null ? json.decode(response.body)['name'] : id,
        title: title,
        start: start,
        category: category,
        labels: labels,
        superProjectId: superProjectName,
        syncStatus: (await authData.isAuth)
            ? (await _isConnected ? SyncStatus.FullySynced : SyncStatus.NewTask)
            : SyncStatus.FullySynced);
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
          superProjectName == null ? "" : superProjectName,
          0,
          task.syncStatus.index
        ],
      ],
    );
    File f = await _localFile;
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

    _tasks[index].labels.addAll(selected);
    _tasks[index].labels = _tasks[index].labels.toSet().toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('AvailableLabels', labels);
    var authData = Provider.of<Auth>(context, listen: false);
    if (await _isConnected && await authData.isAuth) {
      String userId = await authData.userId;
      String token = authData.token.token;
      final url =
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/tasks/${_tasks[index].id}.json?auth=$token";
      var res = await http.patch(
        url,
        body: json.encode(
          {
            'labels': _tasks[index].labels.join('|'),
          },
        ),
      );
    }

    _tasks[index].syncStatus = (await authData.isAuth)
        ? (await _isConnected
            ? (_tasks[index].syncStatus == SyncStatus.UpdatedTask
                ? SyncStatus.FullySynced
                : _tasks[index].syncStatus)
            : (_tasks[index].syncStatus != SyncStatus.NewTask
                ? SyncStatus.UpdatedTask
                : SyncStatus.NewTask))
        : SyncStatus.FullySynced;
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
        DateTime.now().difference(_tasks[index].latestPause);
    var authData = Provider.of<Auth>(context, listen: false);
    if (await _isConnected && await authData.isAuth) {
      String userId = await authData.userId;
      String token = authData.token.token;
      final url =
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/tasks/${_tasks[index].id}.json?auth=$token";
      var res = await http.patch(
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

    _tasks[index].syncStatus = (await authData.isAuth)
        ? (await _isConnected
            ? (_tasks[index].syncStatus == SyncStatus.UpdatedTask
                ? SyncStatus.FullySynced
                : _tasks[index].syncStatus)
            : (_tasks[index].syncStatus != SyncStatus.NewTask
                ? SyncStatus.UpdatedTask
                : SyncStatus.NewTask))
        : SyncStatus.FullySynced;
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
    var authData = Provider.of<Auth>(context, listen: false);
    if (await _isConnected && await authData.isAuth) {
      String userId = await authData.userId;
      String token = authData.token.token;
      final url =
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/tasks/${_tasks[index].id}.json?auth=$token";
      var res = await http.patch(
        url,
        body: json.encode(
          {
            'isRunning': false,
            'isPaused': true,
            'pauses': _tasks[index].pauses,
            'latestPause': DateFormat("dd-MM-yyyy HH:mm:ss")
                .format(_tasks[index].latestPause),
            'labels': _tasks[index].labels.isEmpty
                ? null
                : _tasks[index].labels.join("|")
          },
        ),
      );
    }

    _tasks[index].syncStatus = (await authData.isAuth)
        ? (await _isConnected
            ? (_tasks[index].syncStatus == SyncStatus.UpdatedTask
                ? SyncStatus.FullySynced
                : _tasks[index].syncStatus)
            : (_tasks[index].syncStatus != SyncStatus.NewTask
                ? SyncStatus.UpdatedTask
                : SyncStatus.NewTask))
        : SyncStatus.FullySynced;
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

    var authData = Provider.of<Auth>(context, listen: false);
    if (await _isConnected && await authData.isAuth) {
      String userId = await authData.userId;
      String token = authData.token.token;
      final url =
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/tasks/${_tasks[index].id}.json?auth=$token";
      final res = await http.patch(
        url,
        body: json.encode(
          {
            'isRunning': _tasks[index].isRunning,
            'isPaused': _tasks[index].isPaused,
            'latestPause': DateFormat("dd-MM-yyyy HH:mm:ss")
                .format(_tasks[index].latestPause),
            'end': DateFormat("dd-MM-yyyy HH:mm:ss").format(_tasks[index].end),
            'labels': _tasks[index].labels.isEmpty
                ? null
                : _tasks[index].labels.join("|")
          },
        ),
      );
    }

    _tasks[index].syncStatus = (await authData.isAuth)
        ? (await _isConnected
            ? (_tasks[index].syncStatus == SyncStatus.UpdatedTask
                ? SyncStatus.FullySynced
                : _tasks[index].syncStatus)
            : (_tasks[index].syncStatus != SyncStatus.NewTask
                ? SyncStatus.UpdatedTask
                : SyncStatus.NewTask))
        : SyncStatus.FullySynced;
    await writeCsv(_tasks);
    notifyListeners();
  }

  Future<void> syncWithFirebase() async {
    if (await _isConnected) {
      Map<String, dynamic> syncedTasks;
      var authData = Provider.of<Auth>(context, listen: false);
      if (await authData.isAuth) {
        String userId = await authData.userId;
        String token = authData.token.token;
        final url =
            "https://taskflow1-4a77f.firebaseio.com/Users/$userId/tasks.json?auth=$token";
        final res = await http.get(url);
        syncedTasks = json.decode(res.body);
      }
      _tasks.clear();
      syncedTasks.forEach((id, data) {
        _tasks.add(Task(
            id: id,
            title: data['title'],
            start: parser.parse(data['start']),
            category: data['category'],
            isRunning: data['isRunning'],
            isPaused: data['isPaused'],
            latestPause: data.containsKey('latestPause')
                ? parser.parse(data['latestPause'])
                : null,
            labels: data.containsKey('labels') ? data['labels'].split('|') : [],
            superProjectId: data.containsKey('superProjectName')
                ? data['superProjectName']
                : '',
            goalTime: data.containsKey('goalTime')
                ? Duration(seconds: data['goalTime'])
                : Duration.zero,
            pauses: data.containsKey('pauses') ? data['pauses'] : 0,
            pauseTime: data.containsKey('pauseTime')
                ? Duration(seconds: data['pauseTime'])
                : Duration.zero,
            end: data.containsKey('end') ? parser.parse(data['end']) : null,
            syncStatus: SyncStatus.FullySynced));
      });
      await writeCsv(_tasks);
    }
  }

  Future<void> syncEngine() async {
    var authData = Provider.of<Auth>(context, listen: false);
    await loadData();
    if (_tasks != null && await authData.isAuth) {
      String userId = await authData.userId;
      String token = authData.token.token;
      _tasks.asMap().forEach(
        (i, task) async {
          if (await _isConnected) {
            if (task.syncStatus == SyncStatus.UpdatedTask) {
              final url =
                  "https://taskflow1-4a77f.firebaseio.com/Users/$userId/tasks/${task.id}.json?auth=$token";
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
                    'labels': task.labels.join("|"),
                  },
                ),
              );
            } else if (task.syncStatus == SyncStatus.NewTask) {
              final url =
                  "https://taskflow1-4a77f.firebaseio.com/Users/$userId/tasks.json?auth=$token";
              final res = await http.post(
                url,
                body: json.encode(
                  {
                    'title': task.title,
                    'start':
                        DateFormat("dd-MM-yyyy HH:mm:ss").format(task.start),
                    'latestPause': task.latestPause != null
                        ? DateFormat("dd-MM-yyyy HH:mm:ss")
                            .format(task.latestPause)
                        : null,
                    'end': task.end != null
                        ? DateFormat("dd-MM-yyyy HH:mm:ss").format(task.end)
                        : null,
                    'pauses': task.pauses,
                    'pauseTime': task.pauseTime != null
                        ? task.pauseTime.inSeconds
                        : null,
                    'isRunning': task.isRunning,
                    'isPaused': task.isPaused,
                    'category': task.category,
                    'labels': task.labels.join("|"),
                    'goalTime':
                        task.goalTime != null ? task.goalTime.inSeconds : null
                  },
                ),
              );
              _tasks[i].id = json.decode(res.body)['name'];
            }
            _tasks[i].syncStatus = SyncStatus.FullySynced;
          }
        },
      );
      await writeCsv(_tasks);
    }
  }
}
