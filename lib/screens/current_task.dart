import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/providers/tasks.dart';

import '../providers/task.dart';

class DrawCircle extends CustomPainter {
  Paint _paint;

  DrawCircle() {
    _paint = Paint()
      ..color = Colors.lightGreenAccent
      ..strokeWidth = 7.0
      ..style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(100.0, 30.0), 120.0, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CurrentTaskScreen extends StatefulWidget {
  static const routeName = '/current-task';
  final Task task;
  CurrentTaskScreen({this.task});

  @override
  _CurrentTaskScreenState createState() => _CurrentTaskScreenState();
}

class _CurrentTaskScreenState extends State<CurrentTaskScreen> {
  Timer _timer;
  String _time;
  List<String> _categories;
  String _title;
  List<String> _labels;
  Duration _resumeTime;
  @override
  void initState() {
    Task _task = widget.task;
    _timer = Timer(const Duration(seconds: 1), () {});
    _categories = _task.categories;
    _labels = _task.labels;
    _title = _task.title;
    _resumeTime = _task.getRunningTime();
    _time = _resumeTime.inHours.toString().padLeft(2, "0") +
        ":" +
        _resumeTime.inMinutes.remainder(60).toString().padLeft(2, "0") +
        ":" +
        _resumeTime.inSeconds.remainder(60).toString().padLeft(2, "0");
    startTimer();
    watch.start();
    if (widget.task.latestPause != null) widget.task.resume();
    super.initState();
  }

  var watch = Stopwatch();
  bool paused = false;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (timer) => setState(
        () {
          if (!paused) {
            _time = (watch.elapsed + _resumeTime)
                    .inHours
                    .toString()
                    .padLeft(2, "0") +
                ":" +
                (watch.elapsed + _resumeTime)
                    .inMinutes
                    .remainder(60)
                    .toString()
                    .padLeft(2, "0") +
                ":" +
                (watch.elapsed + _resumeTime)
                    .inSeconds
                    .remainder(60)
                    .toString()
                    .padLeft(2, "0");
          } else {
            timer.cancel();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    watch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (!paused) widget.task.pause();
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'TASKFLOW',
          style: Theme.of(context).appBarTheme.textTheme.headline6,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Stack(
                children: <Widget>[
                  Text(
                    _time,
                    style: TextStyle(
                      fontSize: 50,
                      color: Theme.of(context).textTheme.headline6.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CustomPaint(
                    painter: DrawCircle(),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      FittedBox(
                        child: Text(
                          _title.toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).textTheme.headline6.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              paused ? Icons.play_arrow : Icons.pause,
                              size: 35,
                              color: Theme.of(context).accentColor,
                            ),
                            onPressed: () {
                              if (paused) {
                                watch.start();
                                widget.task.resume();
                              } else {
                                watch.stop();
                                widget.task.pause();
                              }
                              paused = !paused;
                              startTimer();
                            },
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.stop,
                              size: 35,
                              color: Theme.of(context).errorColor,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Card(
                  margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  color: Color.fromRGBO(37, 37, 37, 1),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'CATEGORIES',
                          style: TextStyle(
                            color: Color.fromRGBO(120, 120, 120, 1),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          _categories.join(", "),
                          style: TextStyle(
                            color: Color.fromRGBO(227, 227, 227, 1),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  color: Color.fromRGBO(37, 37, 37, 1),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'LABELS',
                          style: TextStyle(
                            color: Color.fromRGBO(120, 120, 120, 1),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          _labels.join(", ").replaceAll(new RegExp(r"'"), ""),
                          style: TextStyle(
                            color: Color.fromRGBO(227, 227, 227, 1),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
