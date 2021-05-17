import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../utils/is_connected.dart';
import 'task.dart';

enum PaymentMode { fixed, rate, none }

class Project {
  BuildContext context;
  SendPort transactionSendPort;

  SyncStatus syncStatus;
  String id;
  final String name;
  final DateTime start;
  DateTime? end;
  DateTime deadline;
  final String category;
  List<String> labels;
  List<Task> subTasks;
  PaymentMode paymentMode;
  double rate;
  String client;

  Project({
    required this.context,
    required this.transactionSendPort,
    this.syncStatus = SyncStatus.newTask,
    required this.id,
    required this.name,
    required this.start,
    this.end,
    required this.deadline,
    required this.category,
    this.labels = const [],
    this.subTasks = const [],
    this.paymentMode = PaymentMode.none,
    this.rate = 0,
    this.client = '',
  });

  Future<String> get _localPath async {
    // gets the AppData directory
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    // gets the st_projectid.csv file from the AppData directory
    final path = await _localPath;
    return File('$path/st_${id.replaceAll(RegExp(r'[:. \-]'), "")}.csv');
  }

  Duration get totalPauseTime {
    Duration total = Duration.zero;
    return total =
        subTasks.fold(total, (total, element) => total + element.pauseTime);
  }

  int get totalPauses {
    int total = 0;
    return total = subTasks.fold(total, (total, element) {
      return total + element.pauses;
    });
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
              t.syncStatus.index,
            ])
        .toList());
    final File f = await _localFile;
    await f.writeAsString(rows, mode: FileMode.writeOnly);
  }

  DateFormat parser = DateFormat("dd-MM-yyyy HH:mm:ss");

  Future<void> loadData() async {
    // function to load the data from the tasks.csv file into Task
    // models which are then put into the subTasks list

    final String csvPath = await _localPath;
    final String csvString =
        await File('$csvPath/st_${id.replaceAll(RegExp(r'[:. \-]'), "")}.csv')
            .readAsString();

    // String csvString = await rootBundle.loadString('assets/data/tasks.csv');
    final List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(csvString);

    subTasks = [];
    for (final List<dynamic> row in rowsAsListOfValues) {
      subTasks.add(
        Task(
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
          syncStatus: SyncStatus.values[row[9] as int],
          category: category,
        ),
      );
    }
  }

  Future<void> addSubTask({
    required BuildContext ctx,
    required String id,
    required DateTime start,
    required String title,
  }) async {
    http.Response? response;
    final firebaseUser = context.read<User?>();

    if (await isConnected() && firebaseUser != null) {
      final userId = firebaseUser.uid;
      final String? token = (await firebaseUser.getIdTokenResult()).token;
      final Uri url = Uri.parse(
          "${env['FIREBASE_URL']}/Users/$userId/projects/${this.id}/subtasks.json?auth=$token");
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

    final Task newTask = Task(
      syncStatus: (firebaseUser != null)
          ? (await isConnected() ? SyncStatus.fullySynced : SyncStatus.newTask)
          : SyncStatus.fullySynced,
      start: start,
      title: title,
      id: response != null ? json.decode(response.body)["name"] as String : id,
      category: category,
    );
    subTasks.add(newTask);
    await writeCsv(subTasks);
  }

  String cardTags({bool requireLabels = true}) {
    if (paymentMode != PaymentMode.none) {
      return 'Paid, $category${requireLabels ? (', ${labels.join(', ')}') : ''}';
    }
    return '$category, ${labels.join(', ')}';
  }

  DateTime get lastActive {
    DateTime last = subTasks.isNotEmpty ? subTasks.first.latestPause! : start;

    for (final Task subTask in subTasks) {
      if (subTask.latestPause!.isAfter(last)) last = subTask.latestPause!;
    }
    return last;
  }

  Duration get elapsedDuration {
    return lastActive.difference(start);
  }

  Duration get workingDuration {
    Duration runningTime = Duration.zero;
    return runningTime = subTasks.fold(
      runningTime,
      (runningTime, st) => runningTime + st.getRunningTime(),
    );
  }

  String get deadlineString {
    return '${DateTime.now().difference(start).inDays}d / ${deadline.difference(start).inDays}d';
  }

  String get earnings {
    if (paymentMode == PaymentMode.none) {
      return '-';
    } else if (paymentMode == PaymentMode.fixed) {
      return '₹${rate.toStringAsFixed(2)}';
    } else {
      return '₹${(rate * workingDuration.inHours).toStringAsFixed(2)}';
    }
  }

  double get earningsAsNum {
    if (paymentMode == PaymentMode.none) {
      return 0;
    } else if (paymentMode == PaymentMode.fixed) {
      return rate;
    } else {
      return rate * workingDuration.inHours;
    }
  }

  Future<void> resume(int index) async {
    // Arguments => index: The index of the task to be resumed
    // Resumes the task at 'index' in the subTasks list

    subTasks[index].isRunning = true;
    subTasks[index].isPaused = false;
    subTasks[index].pauseTime +=
        DateTime.now().difference(subTasks[index].latestPause!);

    final firebaseUser = context.read<User?>();
    if (await isConnected() && firebaseUser != null) {
      final userId = firebaseUser.uid;
      final String? token = (await firebaseUser.getIdTokenResult()).token;
      final Uri url = Uri.parse(
          "${env['FIREBASE_URL']}/Users/$userId/projects/$id/subtasks/${subTasks[index].id}.json?auth=$token");
      await http.patch(
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
        ? (await isConnected()
            ? (subTasks[index].syncStatus == SyncStatus.updatedTask
                ? SyncStatus.fullySynced
                : subTasks[index].syncStatus)
            : (subTasks[index].syncStatus != SyncStatus.newTask
                ? SyncStatus.updatedTask
                : SyncStatus.newTask))
        : SyncStatus.fullySynced;
    await writeCsv(subTasks);
  }

  Future<void> pause(int index) async {
    // Arguments => index: The index of the task to be resumed
    // Resumes the task at 'index' in the subTasks list
    subTasks[index].isRunning = false;
    subTasks[index].isPaused = true;
    subTasks[index].pauses++;
    subTasks[index].latestPause = DateTime.now();
    final firebaseUser = context.read<User?>();
    if (await isConnected() && firebaseUser != null) {
      final userId = firebaseUser.uid;
      final String? token = (await firebaseUser.getIdTokenResult()).token;
      final Uri url = Uri.parse(
          "${env['FIREBASE_URL']}/Users/$userId/projects/$id/subtasks/${subTasks[index].id}.json?auth=$token");
      await http.patch(
        url,
        body: json.encode(
          {
            'isRunning': false,
            'isPaused': true,
            'pauses': subTasks[index].pauses,
            'latestPause': DateFormat("dd-MM-yyyy HH:mm:ss")
                .format(subTasks[index].latestPause!),
          },
        ),
      );
    }
    subTasks[index].syncStatus = (firebaseUser != null)
        ? (await isConnected()
            ? (subTasks[index].syncStatus == SyncStatus.updatedTask
                ? SyncStatus.fullySynced
                : subTasks[index].syncStatus)
            : (subTasks[index].syncStatus != SyncStatus.newTask
                ? SyncStatus.updatedTask
                : SyncStatus.newTask))
        : SyncStatus.fullySynced;
    await writeCsv(subTasks);
  }

  Future<void> complete(int index) async {
    subTasks[index].isRunning = false;
    subTasks[index].isPaused = true;
    subTasks[index].end = DateTime.now();
    subTasks[index].latestPause = subTasks[index].end;

    final firebaseUser = context.read<User?>();
    if (await isConnected() && firebaseUser != null) {
      final userId = firebaseUser.uid;
      final String? token = (await firebaseUser.getIdTokenResult()).token;
      final Uri url = Uri.parse(
          "${env['FIREBASE_URL']}/Users/$userId/projects/$id/subtasks/${subTasks[index].id}.json?auth=$token");
      await http.patch(
        url,
        body: json.encode(
          {
            'isRunning': subTasks[index].isRunning,
            'isPaused': subTasks[index].isPaused,
            'latestPause': DateFormat("dd-MM-yyyy HH:mm:ss")
                .format(subTasks[index].latestPause!),
            'end':
                DateFormat("dd-MM-yyyy HH:mm:ss").format(subTasks[index].end!),
          },
        ),
      );
    }

    subTasks[index].syncStatus = (firebaseUser != null)
        ? (await isConnected()
            ? (subTasks[index].syncStatus == SyncStatus.updatedTask
                ? SyncStatus.fullySynced
                : subTasks[index].syncStatus)
            : (subTasks[index].syncStatus != SyncStatus.newTask
                ? SyncStatus.updatedTask
                : SyncStatus.newTask))
        : SyncStatus.fullySynced;

    await writeCsv(subTasks);
  }

  Future<void> pullFromFireBase() async {
    if (await isConnected()) {
      late Map<String, dynamic>? syncedTasks;
      final firebaseUser = context.read<User?>();
      if (firebaseUser != null) {
        final userId = firebaseUser.uid;
        final String? token = (await firebaseUser.getIdTokenResult()).token;
        final Uri url = Uri.parse(
            "${env['FIREBASE_URL']}/Users/$userId/projects/$id/subtasks.json?auth=$token");
        final res = await http.get(url);
        syncedTasks = json.decode(res.body) as Map<String, dynamic>?;
      }
      subTasks = [];
      subTasks.clear();

      if (syncedTasks != null) {
        syncedTasks.forEach(
          (id, data) {
            subTasks.add(
              Task(
                //T_T
                id: id,
                title: data['title'] as String,
                start: parser.parse(data['start'] as String),
                isRunning: data['isRunning'] as bool,
                isPaused: data['isPaused'] as bool,
                latestPause:
                    (data as Map<String, dynamic>).containsKey('latestPause')
                        ? parser.parse(data['latestPause'] as String)
                        : null,
                pauses: data.containsKey('pauses') ? data['pauses'] as int : 0,
                pauseTime: data.containsKey('pauseTime')
                    ? Duration(seconds: data['pauseTime'] as int)
                    : Duration.zero,
                end: data.containsKey('end')
                    ? parser.parse(data['end'] as String)
                    : null,
                syncStatus: SyncStatus.fullySynced,
                category: category,
              ),
            );
          },
        );
        await writeCsv(subTasks);
      }
    }
  }

  Future<void> syncEngine() async {
    if (await isConnected()) {
      final firebaseUser = context.read<User?>();
      await loadData();
      if (firebaseUser != null) {
        final userId = firebaseUser.uid;
        final String? token = (await firebaseUser.getIdTokenResult()).token;
        // debugPrint("Token $token");
        for (int i = 0; i < subTasks.length; i++) {
          final Task task = subTasks[i];
          if (task.syncStatus == SyncStatus.updatedTask) {
            final Uri url = Uri.parse(
                "${env['FIREBASE_URL']}/Users/$userId/projects/$id/subtasks/${task.id}.json?auth=$token");
            await http.patch(
              url,
              body: json.encode(
                {
                  'isRunning': task.isRunning,
                  'isPaused': task.isPaused,
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
                "${env['FIREBASE_URL']}/Users/$userId/projects/$id/subtasks.json?auth=$token");
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
                  'pauses': task.pauses,
                  'pauseTime': task.pauseTime.inSeconds,
                  'isRunning': task.isRunning,
                  'isPaused': task.isPaused,
                },
              ),
            );
            // debugPrint('${json.decode(res.body)}');
            subTasks[i].id = json.decode(res.body)['name'] as String;
          }
          subTasks[i].syncStatus = SyncStatus.fullySynced;
        }
        await writeCsv(subTasks);
      }
    }
  }

  Future<void> purgeSubTasks() async {
    final File subTaskFile = await _localFile;
    await subTaskFile.delete();
  }
}
