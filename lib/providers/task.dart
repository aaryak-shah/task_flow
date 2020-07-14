import 'package:flutter/foundation.dart';

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
    this.pauseTime = const Duration(),
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
    (hrs / 10).floor() == 0 ? h = '0' + hrs.toString() + ':' : h = hrs.toString() + ':';
    (mins / 10).floor() == 0 ? m = '0' + mins.toString() : m = mins.toString();
    return (h + m);
  }
}
