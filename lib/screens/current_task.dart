import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tasks.dart';
import '../widgets/new_labels.dart';

import '../providers/task.dart';

void showLabelForm(BuildContext context, int i) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (_) {
      return GestureDetector(
        onTap: () {},
        child: NewLabels(i),
        behavior: HitTestBehavior.opaque,
      );
    },
  );
}

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
  final int index;
  final bool wasSuspended;
  CurrentTaskScreen({this.index, this.wasSuspended});

  @override
  _CurrentTaskScreenState createState() => _CurrentTaskScreenState();
}

class _CurrentTaskScreenState extends State<CurrentTaskScreen> {
  var _provider;
  Timer _timer;
  String _time;
  String _category;
  String _title;
  List<String> _labels;
  Duration _resumeTime;

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      var _provider = Provider.of<Tasks>(context, listen: true);
      Task _task = _provider.tasks[widget.index];
      _timer = Timer(const Duration(seconds: 1), () {});
      _category = _task.category;
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
      if (_task.latestPause != null) {
        widget.wasSuspended ? _provider.unSuspend(widget.index) : _provider.resume(widget.index);
      }
      _isInit = false;
    }
    super.didChangeDependencies();
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
    _provider = Provider.of<Tasks>(context);
    return WillPopScope(
      onWillPop: () async {
        if (!paused) await _provider.pause(widget.index);
        Navigator.pushReplacementNamed(context, '/');
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              if (!paused) await _provider.pause(widget.index);
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
                          fit: BoxFit.cover,
                          child: Text(
                            _title.length <= 21
                                ? _title.toUpperCase()
                                : (_title.substring(0, 21) + '...')
                                    .toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  Theme.of(context).textTheme.headline6.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                paused ? Icons.play_arrow : Icons.pause,
                                size: 35,
                                color: Theme.of(context).accentColor,
                              ),
                              onPressed: () async {
                                if (paused) {
                                  watch.start();
                                  await _provider.resume(widget.index);
                                } else {
                                  watch.stop();
                                  await _provider.pause(widget.index);
                                }
                                paused = !paused;
                                startTimer();
                              },
                            ),
                            // SizedBox(
                            //   width: 6,
                            // ),
                            IconButton(
                              icon: Icon(
                                Icons.stop,
                                size: 35,
                                color: Theme.of(context).errorColor,
                              ),
                              onPressed: () async {
                                watch.reset();
                                watch.stop();
                                paused = true;
                                await _provider.complete(widget.index);
                                Navigator.pushReplacementNamed(context, '/');
                              },
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
                            'CATEGORY',
                            style: TextStyle(
                              color: Color.fromRGBO(120, 120, 120, 1),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            _category,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'LABELS',
                                style: TextStyle(
                                  color: Color.fromRGBO(120, 120, 120, 1),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_box),
                                onPressed: () async {
                                  // List<String> availableLabels =
                                  // await Provider.of<Task>(context, listen: false)
                                  //     .availableLabels;
                                  showLabelForm(context, widget.index);
                                },
                              )
                            ],
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
      ),
    );
  }
}
