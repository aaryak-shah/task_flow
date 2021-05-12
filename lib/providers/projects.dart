import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_flow/models/task.dart';
import 'package:http/http.dart' as http;

import '../models/project.dart';

class Projects with ChangeNotifier {
  BuildContext context;
  Projects(this.context);

  List<Project> _projects = [];

  List<Project> get projects {
    return [..._projects];
  }

  Future<String> get _localPath async {
    // gets the AppData directory
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    // gets the projects.csv file from the AppData directory
    final path = await _localPath;
    return File('$path/projects.csv');
  }

  Future<void> writeCsv(List<Project> projects) async {
    // Arguments => projects: a list of Project objects to be written to the projects.csv file
    final rows = ListToCsvConverter().convert(projects
        .map((p) => [
              p.id,
              p.name,
              DateFormat("dd-MM-yyyy HH:mm:ss").format(p.start),
              p.end != null
                  ? DateFormat("dd-MM-yyyy HH:mm:ss").format(p.end)
                  : "",
              DateFormat("dd-MM-yyyy HH:mm:ss").format(p.deadline),
              p.category,
              p.labels.isNotEmpty ? p.labels.join("|") : "",
              p.paymentMode.index,
              p.rate,
              p.client,
              p.syncStatus.index,
            ])
        .toList());
    File f = await _localFile;
    print("projects.csv before");
    print(await f.readAsString());
    await f.writeAsString(rows, mode: FileMode.writeOnly);
    print("projects.csv after");
    print(await f.readAsString());
    notifyListeners();
  }

  DateFormat parser = DateFormat("dd-MM-yyyy HH:mm:ss");

  Future<void> loadData() async {
    // function to load the data from the tasks.csv file into Task
    // models which are then put into the _projects list

    File csvFile = await _localFile;
    String csvString = await csvFile.readAsString();
    String csvPath = await _localPath;
    // String csvString = await rootBundle.loadString('assets/data/tasks.csv');
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(csvString);
    _projects = [];

    for (var row in rowsAsListOfValues) {
      List<Task> subTasks = [];
      String subTaskCsvString = await File(
              '$csvPath/st_${row[0].replaceAll(new RegExp(r'[:. \-]'), "")}.csv')
          .readAsString();
      List<List<dynamic>> subTasksAsListOfValues =
          const CsvToListConverter().convert(subTaskCsvString);

      subTasks = [];
      subTasksAsListOfValues.forEach((stRow) {
        subTasks.add(
          Task(
            id: stRow[0],
            title: stRow[1].toString(),
            start: parser.parse(stRow[2]),
            latestPause: stRow[3].isNotEmpty ? parser.parse(stRow[3]) : null,
            end: stRow[4].isNotEmpty ? parser.parse(stRow[4]) : null,
            pauses: stRow[5],
            pauseTime: Duration(seconds: stRow[6]),
            isRunning: stRow[7] == 1,
            isPaused: stRow[8] == 1,
            syncStatus: SyncStatus.values[stRow[9]],
            category: row[5],
          ),
        );
      });
      // _projects = [];
      Project project = Project(
        context,
        id: row[0],
        name: row[1],
        start: parser.parse(row[2]),
        end: row[3].isNotEmpty ? parser.parse(row[3]) : null,
        deadline: parser.parse(row[4]),
        category: row[5],
        labels: row[6] != "" ? row[6].split("|") : [],
        paymentMode: PaymentMode.values[row[7]],
        rate: row[8],
        client: row[9],
        subTasks: subTasks,
        syncStatus: SyncStatus.values[row[10]],
      );
      _projects.add(project);
    }
    notifyListeners();
  }

  Future<String> addProject({
    required String id,
    required String name,
    required DateTime start,
    required DateTime deadline,
    required String category,
    // List<String> labels,
    required PaymentMode paymentMode,
    required double rate,
    required String client,
  }) async {
    var response;
    final firebaseUser = context.read<User>();
    if (await _isConnected && firebaseUser != null) {
      String userId = firebaseUser.uid;
      String token = (await firebaseUser.getIdTokenResult()).token;
      final url =
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/projects.json?auth=$token";
      response = await http.post(
        url,
        body: json.encode(
          {
            'name': name,
            'start': DateFormat("dd-MM-yyyy HH:mm:ss").format(start),
            'deadline': DateFormat("dd-MM-yyyy HH:mm:ss").format(deadline),
            'category': category,
            'paymentMode': paymentMode.index,
            'rate': rate,
            'client': client,
          },
        ),
      );
    }

    Project newProject = Project(
      context,
      name: name,
      start: start,
      deadline: deadline,
      category: category,
      labels: [],
      id: response != null ? json.decode(response.body)['name'] : id,
      paymentMode: paymentMode,
      rate: rate,
      client: client,
      subTasks: [],
      syncStatus: (firebaseUser != null)
          ? (await _isConnected ? SyncStatus.FullySynced : SyncStatus.NewTask)
          : SyncStatus.FullySynced,
    );
    _projects.add(newProject);
    print("new project");
    await writeCsv(_projects);
    notifyListeners();
    return newProject.id;
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

  Future<void> addLabels(
    final int index,
    final List<String> selected,
    final List<String> labels,
  ) async {
    // Arguments => index: The index of the task in the list to which the labels are to be added,
    //              selected: The list of labels to be added to the Task,
    //              labels: The list of available labels (shown as chips),
    //
    // Adds 'selected' labels to the task at 'index' in the _projects list
    // Also updates the 'AvailableLabels' key in SharedPreferences

    _projects[index].labels.addAll(selected);
    _projects[index].labels = _projects[index].labels.toSet().toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('AvailableLabels', labels);
    final firebaseUser = context.read<User>();
    if (await _isConnected && firebaseUser != null) {
      String userId = firebaseUser.uid;
      String token = (await firebaseUser.getIdTokenResult()).token;
      final url =
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/projects/${_projects[index].id}.json?auth=$token";
      await http.patch(
        url,
        body: json.encode(
          {
            'labels': _projects[index].labels.join('|'),
          },
        ),
      );
    }

    _projects[index].syncStatus = (firebaseUser != null)
        ? (await _isConnected
            ? (_projects[index].syncStatus == SyncStatus.UpdatedTask
                ? SyncStatus.FullySynced
                : _projects[index].syncStatus)
            : (_projects[index].syncStatus != SyncStatus.NewTask
                ? SyncStatus.UpdatedTask
                : SyncStatus.NewTask))
        : SyncStatus.FullySynced;
    await writeCsv(_projects);
    notifyListeners();
  }

  Future<void> complete(int index) async {
    _projects[index].end = DateTime.now();
    final firebaseUser = context.read<User>();
    if (await _isConnected && firebaseUser != null) {
      String userId = firebaseUser.uid;
      String token = (await firebaseUser.getIdTokenResult()).token;
      final url =
          "https://taskflow1-4a77f.firebaseio.com/Users/$userId/projects/${_projects[index].id}.json?auth=$token";
      await http.patch(
        url,
        body: json.encode(
          {
            'end':
                DateFormat("dd-MM-yyyy HH:mm:ss").format(_projects[index].end),
          },
        ),
      );
    }

    _projects[index].syncStatus = (firebaseUser != null)
        ? (await _isConnected
            ? (_projects[index].syncStatus == SyncStatus.UpdatedTask
                ? SyncStatus.FullySynced
                : _projects[index].syncStatus)
            : (_projects[index].syncStatus != SyncStatus.NewTask
                ? SyncStatus.UpdatedTask
                : SyncStatus.NewTask))
        : SyncStatus.FullySynced;
    await writeCsv(_projects);
  }

  Future<List<String>> get availableLabels async {
    // getter to fetch the list of available labels from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('AvailableLabels') ?? [];
  }

  int projectIndex(String id) {
    return projects.indexWhere((project) => project.id == id);
  }

  Map<String, List<double>> get clients {
    final Map<String, List<double>> clientMap = {};
    _projects.forEach((project) {
      if (project.client.isNotEmpty) clientMap[project.client] = [0, 0];
    });
    _projects.forEach(
      (project) {
        // if (project.client == "Test") print(project.workingDuration.inSeconds);
        if (project.client.isNotEmpty)
          clientMap.update(
            project.client,
            (value) => [
              value[0] + project.workingDuration.inSeconds,
              value[1] + project.earningsAsNum
            ],
          );
      },
    );
    return clientMap;
  }

  List<Project> projectsByClient(String client) {
    return projects
        .where(
            (project) => project.client.toLowerCase() == client.toLowerCase())
        .toList();
  }

  Future<void> purgeProjects() async {
    _projects = [];
    await writeCsv([]);
  }

  Future<void> pullFromFireBase() async {
    if (await _isConnected) {
      late Map<String, dynamic>? syncedProjects;

      final firebaseUser = context.read<User>();

      if (firebaseUser != null) {
        String userId = firebaseUser.uid;
        String token = (await firebaseUser.getIdTokenResult()).token;
        final url =
            "https://taskflow1-4a77f.firebaseio.com/Users/$userId/projects.json?auth=$token";
        final res = await http.get(url);
        syncedProjects = json.decode(res.body);
      }

      _projects.clear();

      if (syncedProjects != null) {
        for (MapEntry<String, dynamic> m in syncedProjects.entries) {
          Project p = Project(
            context,
            id: m.key,
            name: m.value['name'],
            start: parser.parse(m.value['start']),
            category: m.value['category'],
            labels: m.value.containsKey('labels')
                ? m.value['labels'].split('|')
                : [],
            deadline: parser.parse(m.value['deadline']),
            end: m.value.containsKey('end')
                ? parser.parse(m.value['end'])
                : null,
            paymentMode: PaymentMode.values[m.value['paymentMode']],
            rate: m.value['rate'],
            client: m.value['client'],
            syncStatus: SyncStatus.FullySynced,
          );
          _projects.add(p);
          File f = File(
              '${await _localPath}/st_${p.id.replaceAll(new RegExp(r'[:. \-]'), "")}.csv');
          f.writeAsStringSync('');
          await p.pullFromFireBase();
        }
        print("pull from firebase");
        await writeCsv(_projects);
      }
    }
  }

  Future<void> syncEngine() async {
    final firebaseUser = context.read<User>();

    await loadData();
    if (firebaseUser != null) {
      String userId = firebaseUser.uid;
      String token = (await firebaseUser.getIdTokenResult()).token;
      for (int i = 0; i < _projects.length; i++) {
        Project project = _projects[i];
        if (await _isConnected) {
          if (project.syncStatus == SyncStatus.UpdatedTask) {
            final url =
                "https://taskflow1-4a77f.firebaseio.com/Users/$userId/projects/${project.id}.json?auth=$token";
            await http.patch(
              url,
              body: json.encode(
                {
                  'end': project.end != null
                      ? DateFormat("dd-MM-yyyy HH:mm:ss").format(project.end)
                      : null,
                  'labels': project.labels.join("|"),
                },
              ),
            );
          } else if (project.syncStatus == SyncStatus.NewTask) {
            final url =
                "https://taskflow1-4a77f.firebaseio.com/Users/$userId/projects.json?auth=$token";
            final res = await http.post(
              url,
              body: json.encode(
                {
                  'name': project.name,
                  'start':
                      DateFormat("dd-MM-yyyy HH:mm:ss").format(project.start),
                  'deadline': DateFormat("dd-MM-yyyy HH:mm:ss")
                      .format(project.deadline),
                  'category': project.category,
                  'paymentMode': project.paymentMode.index,
                  'rate': project.rate,
                  'client': project.client,
                  'end': project.end != null
                      ? DateFormat("dd-MM-yyyy HH:mm:ss").format(project.end)
                      : null,
                  'labels': project.labels.join("|"),
                },
              ),
            );
            final path = await _localPath;
            String oldId = project.id;
            _projects[i].id = json.decode(res.body)['name'];
            await File(
                    '$path/st_${oldId.replaceAll(new RegExp(r'[:. \-]'), "")}.csv')
                .rename(
                    '$path/st_${_projects[i].id.replaceAll(new RegExp(r'[:. \-]'), "")}.csv');
          }
          _projects[i].syncStatus = SyncStatus.FullySynced;
        }
      }
      print("sync engine");
      print(_projects.length);
      await writeCsv(_projects);
    }
  }
}
