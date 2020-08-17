import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'project.dart';

class Projects with ChangeNotifier {
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
              p.client
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
    String csvString = await File('$csvPath/projects.csv').readAsString();
    // String csvString = await rootBundle.loadString('assets/data/tasks.csv');
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(csvString);
    _projects = rowsAsListOfValues.map((row) {
      return Project(
          id: row[0],
          name: row[1],
          start: parser.parse(row[2]),
          end: row[3].isNotEmpty ? parser.parse(row[3]) : null,
          deadline: parser.parse(row[4]),
          category: row[5],
          labels: row[6] != "" ? row[6].split("|") : [],
          paymentMode: PaymentMode.values[row[7]],
          rate: double.parse(row[8]),
          client: row[9]);
    }).toList();
    notifyListeners();
  }

  Future<void> addProject({
    String name,
    DateTime start,
    DateTime deadline,
    String category,
    List<String> labels,
    PaymentMode paymentMode,
    double rate,
    String client,
  }) async {
    Project newProject = Project(
      name: name,
      start: start,
      deadline: deadline,
      category: category,
      labels: labels,
      id: DateTime.now().toString(),
      paymentMode: paymentMode,
      rate: rate,
      client: client,
    );
    _projects.add(newProject);
    await writeCsv(_projects);
  }
}
