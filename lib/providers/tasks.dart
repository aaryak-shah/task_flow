import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:nanoid/nanoid.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_flow/models/transaction.dart';

import '../models/task.dart';
import '../utils/is_connected.dart';

class Tasks with ChangeNotifier {
  // variable that stores list of tasks
  BuildContext context;
  SendPort transactionSendPort;
  final List<Task> _tasks = [];
  Box<Task> box;
  Tasks({
    required this.context,
    required this.transactionSendPort,
    required this.box,
  });

  DateFormat parser = DateFormat("dd-MM-yyyy HH:mm:ss");

  Future<void> loadData() async {
    _tasks.clear();
    box.toMap().forEach((key, task) {
      _tasks.add(task);
    });
    print('length: ${_tasks.length}');
  }

  Future<void> purgeOldTasks() async {
    // function to delete (purge) tasks which have a latest pause date
    // older than 1 week so as to save space and computation time

    await loadData();
    box.clear();
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
    box.putAll({for (var t in _tasks) t.id: t});
    notifyListeners();
  }

  // tasks getter, gives a copy of _tasks
  List<Task> get tasks => [..._tasks];

  List<Task> get recentTasks {
    // gets a list of paused tasks whose latest pause is within the past 7 days
    final recent = tasks.where((t) {
      return t.goalTime == Duration.zero &&
          t.isPaused &&
          t.latestPause!
              .isAfter(DateTime.now().subtract(const Duration(days: 7)));
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

  String categoryString(String cid) =>
      _tasks[_tasks.indexWhere((tsk) => cid == tsk.id)].category;

  int getIndex(String id) => _tasks.indexWhere((tsk) => tsk.id == id);

  Future<void> clearTasks() async {
    _tasks.clear();
    box.clear();
  }

  Future<void> addTask(
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

    final id = nanoid();
    final firebaseUser = context.read<User?>();

    if (firebaseUser != null) {
      final userId = firebaseUser.uid;
      final String? token = (await firebaseUser.getIdTokenResult()).token;

      transactionSendPort.send(
        Transaction(
          objectId: id,
          timeStamp: DateTime.now(),
          transactionType: TransactionType.create,
          dataType: DataType.task,
          uid: userId,
          token: token,
          data: {
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
      id: id,
      title: title,
      start: start,
      category: category,
      labels: labels,
      syncStatus: (firebaseUser != null)
          ? (await isConnected() ? SyncStatus.fullySynced : SyncStatus.newTask)
          : SyncStatus.fullySynced,
    );
    await box.put(id, task);
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

    box.put(_tasks[index].id, _tasks[index]);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('AvailableLabels', labels);
    final firebaseUser = context.read<User?>();

    if (firebaseUser != null) {
      final userId = firebaseUser.uid;
      final String? token = (await firebaseUser.getIdTokenResult()).token;
      transactionSendPort.send(
        Transaction(
          objectId: _tasks[index].id,
          timeStamp: DateTime.now(),
          transactionType: TransactionType.update,
          dataType: DataType.task,
          uid: userId,
          token: token,
          data: {
            'labels': _tasks[index].labels?.join('|'),
          },
        ),
      );
    }

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

    box.put(_tasks[index].id, _tasks[index]);
    if (firebaseUser != null) {
      final userId = firebaseUser.uid;
      final String? token = (await firebaseUser.getIdTokenResult()).token;

      transactionSendPort.send(
        Transaction(
          objectId: _tasks[index].id,
          timeStamp: DateTime.now(),
          transactionType: TransactionType.update,
          dataType: DataType.task,
          uid: userId,
          token: token,
          data: {
            'isRunning': true,
            'isPaused': false,
            'pauseTime': _tasks[index].pauseTime.inSeconds,
          },
        ),
      );
    }
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

    box.put(_tasks[index].id, _tasks[index]);
    if (firebaseUser != null) {
      final userId = firebaseUser.uid;
      final String? token = (await firebaseUser.getIdTokenResult()).token;

      transactionSendPort.send(
        Transaction(
          objectId: _tasks[index].id,
          timeStamp: DateTime.now(),
          transactionType: TransactionType.update,
          dataType: DataType.task,
          uid: userId,
          token: token,
          data: {
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

    notifyListeners();
  }

  Future<void> suspend(int index) async {
    // Arguments => index: The index of the task to be suspended
    // Suspends (i.e. Pauses without incrementing the no. of pauses)
    // the task at 'index' in the _tasks list

    _tasks[index].isRunning = false;
    _tasks[index].isPaused = true;
    _tasks[index].latestPause = DateTime.now();

    box.put(_tasks[index].id, _tasks[index]);
    notifyListeners();
  }

  Future<void> unSuspend(int index) async {
    // Arguments => index: The index of the task to be unsuspended
    // Brings the task at 'index' in the _tasks list out of suspension
    // (i.e. Resumes the task without updating the pause time)
    _tasks[index].isRunning = true;
    _tasks[index].isPaused = false;

    box.put(_tasks[index].id, _tasks[index]);
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

    box.put(_tasks[index].id, _tasks[index]);
    if (firebaseUser != null) {
      final userId = firebaseUser.uid;
      final String? token = (await firebaseUser.getIdTokenResult()).token;

      transactionSendPort.send(
        Transaction(
          objectId: _tasks[index].id,
          timeStamp: DateTime.now(),
          transactionType: TransactionType.update,
          dataType: DataType.task,
          uid: userId,
          token: token,
          data: {
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
    notifyListeners();
  }

  Future<void> pullFromFireBase() async {
    print("firebase func ke andar aaya!!");
    if (await isConnected()) {
      print("firebase func ke andar aaya aur net se bhi connected hai!!");
      Map<String, dynamic>? syncedTasks;
      final firebaseUser = context.read<User?>();

      if (firebaseUser != null) {
        final userId = firebaseUser.uid;
        final String? token = (await firebaseUser.getIdTokenResult()).token;
        final Uri url = Uri.parse(
            "${env['FIREBASE_URL']}/Users/$userId/tasks.json?auth=$token");
        final res = await http.get(url);
        syncedTasks = json.decode(res.body) as Map<String, dynamic>?;
      }

      _tasks.clear();
      box.clear();
      if (syncedTasks != null) {
        syncedTasks.forEach((id, data) {
          print('$id');
          final task = Task(
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
          );
          _tasks.add(task);
          print('${_tasks.first.id}');
          box.put(task.id, task);
          print("sab sampann hua!!");
        });
      }
    }
    notifyListeners();
  }
}
