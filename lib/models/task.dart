import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
enum SyncStatus {
  @HiveField(0)
  fullySynced,
  @HiveField(1)
  newTask,
  @HiveField(2)
  updatedTask,
}

@HiveType(typeId: 0)
class Task extends HiveObject {
  // creating a model for Task objects
  @HiveField(0)
  SyncStatus syncStatus;
  @HiveField(1)
  String id;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final DateTime start;
  @HiveField(4)
  DateTime? latestPause;
  @HiveField(5)
  DateTime? end;
  @HiveField(6)
  int pauses;
  @HiveField(7)
  Duration pauseTime;
  @HiveField(8)
  bool isRunning;
  @HiveField(9)
  bool isPaused;
  @HiveField(10)
  final String category;
  @HiveField(11)
  List<String>? labels;
  @HiveField(12)
  final Duration goalTime;

  Task({
    this.syncStatus = SyncStatus.newTask,
    required this.id,
    required this.title,
    required this.start,
    this.latestPause,
    this.end,
    this.pauses = 0,
    this.pauseTime = Duration.zero,
    this.isRunning = true,
    this.isPaused = false,
    required this.category,
    this.labels,
    this.goalTime = Duration.zero,
  });

  Duration getRunningTime() {
    // function to get the total time this task has been running for
    // excluding pause time
    if (end != null) {
      return (end ?? DateTime.now()).difference(start) - pauseTime;
    } else if (isPaused) {
      return (latestPause ?? DateTime.now()).difference(start) - pauseTime;
    } else {
      return DateTime.now().difference(start) - pauseTime;
    }
  }

  String getTimeString(String mode, {required bool showSeconds}) {
    // Arguments => mode: Mode in which the function runs, either 'run' or 'goal'
    //
    // returns the time as a formatted string
    // if mode is 'run', it gets the running time for the task
    // if mode is 'goal', it returns zero

    final Duration getTime = mode == 'run'
        ? getRunningTime()
        : mode == 'goal'
            ? goalTime
            : Duration.zero;
    String h, m, s;
    final int time = getTime.inSeconds;
    final int hrs = (time / 3600).floor();
    final int mins = ((time / 60).floor()) % 60;
    final int seconds = time % 60;
    (hrs / 10).floor() == 0 ? h = '0$hrs:' : h = '$hrs:';
    (mins / 10).floor() == 0 ? m = '0$mins' : m = mins.toString();
    (seconds / 10).floor() == 0 ? s = ':0$seconds' : s = ':$seconds';
    return h + m + (showSeconds ? s : '');
  }
}
