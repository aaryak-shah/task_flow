import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/projects.dart';
import '../providers/tasks.dart';
import '../screens/tabs_screen.dart';
import '../widgets/app_bar.dart';
import '../widgets/new_labels.dart';

// Screen which shows the stopwatch for the currently running task

void showLabelForm(BuildContext context, int i) {
  // Arguments => context: The context for the modal sheet to be created in
  //              i: The index of the task to which the labels are to be added to
  //
  // Opens up a modal sheet to add labels to the current task

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (_) {
      return GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: NewLabels('task', i),
      );
    },
  );
}

class DrawCircle extends CustomPainter {
  // Circle widget that surrounds the stopwatch
  BuildContext context;
  late Paint _paint;

  DrawCircle(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    _paint = Paint()
      ..color = Theme.of(context).accentColor
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CurrentTaskScreen extends StatefulWidget {
  // Arguments => index: The index of the currently running task
  //              wasSuspended: Boolean to indicate whether the task is being brought out of suspension or not

  static const routeName = '/current-task';
  final int index;
  final bool wasSuspended;
  final String superProjectName;
  final String superProjectId;
  const CurrentTaskScreen({
    required this.index,
    required this.wasSuspended,
    required this.superProjectName,
    required this.superProjectId,
  });

  @override
  _CurrentTaskScreenState createState() => _CurrentTaskScreenState();
}

class _CurrentTaskScreenState extends State<CurrentTaskScreen> {
  dynamic _provider;
  late Timer _timer;
  late String _time;
  late String _category;
  late String _title;
  List<String>? _labels;
  late Duration _resumeTime;

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    final dynamic _provider = widget.superProjectName.isEmpty
        ? Provider.of<Tasks>(context, listen: true)
        : Provider.of<Projects>(context, listen: true)
            .projects
            .firstWhere((project) => project.id == widget.superProjectId);
    final Task _task = (widget.superProjectName.isEmpty
        ? _provider.tasks[widget.index]
        : _provider.subTasks[widget.index]) as Task;
    _timer = Timer(const Duration(seconds: 1), () {});
    _category = _task.category;
    _labels = _task.labels;
    _title = _task.title;
    if (_isInit) {
      _resumeTime = _task.getRunningTime();
      _time =
          "${_resumeTime.inHours.toString().padLeft(2, "0")}:${_resumeTime.inMinutes.remainder(60).toString().padLeft(2, "0")}:${_resumeTime.inSeconds.remainder(60).toString().padLeft(2, "0")}";
      startTimer();
      watch.start();
      if (_task.latestPause != null) {
        widget.wasSuspended
            ? _provider.unSuspend(widget.index)
            : _provider.resume(widget.index);
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  Stopwatch watch = Stopwatch();
  bool paused = false;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (!paused) {
        setState(() {
          _time =
              "${(watch.elapsed + _resumeTime).inHours.toString().padLeft(2, "0")}:${(watch.elapsed + _resumeTime).inMinutes.remainder(60).toString().padLeft(2, "0")}:${(watch.elapsed + _resumeTime).inSeconds.remainder(60).toString().padLeft(2, "0")}";
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    paused = true;
    watch.stop();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _provider = widget.superProjectName.isEmpty
        ? Provider.of<Tasks>(context, listen: true)
        : Provider.of<Projects>(context, listen: true)
            .projects
            .firstWhere((project) => project.id == widget.superProjectId);
    return WillPopScope(
      onWillPop: () async {
        if (!paused) await _provider.pause(widget.index);
        if (widget.superProjectName.isEmpty) {
          Navigator.pushReplacementNamed(context, TabsScreen.routeName,
              arguments: 0);
        } else {
          Navigator.of(context).pop();
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: showAppBar(context),
        ),
        body: Column(
          mainAxisAlignment: widget.superProjectName.isNotEmpty
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Text(
                  _time,
                  style: TextStyle(
                    fontSize: 50,
                    color: Theme.of(context).textTheme.headline6!.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.65,
                  height: MediaQuery.of(context).size.width / 1.45,
                  child: CustomPaint(
                    painter: DrawCircle(context),
                  ),
                )
              ],
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  margin: EdgeInsets.only(
                      bottom: widget.superProjectName.isEmpty ? 10 : 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          _title.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).textTheme.headline6!.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(paused ? Icons.play_arrow : Icons.pause,
                                size: 35,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color),
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
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color,
                            ),
                            onPressed: () async {
                              watch.reset();
                              watch.stop();
                              paused = true;
                              await _provider.complete(widget.index);
                              if (widget.superProjectName.isEmpty) {
                                Navigator.pushReplacementNamed(
                                    context, TabsScreen.routeName,
                                    arguments: 0);
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.superProjectName.isNotEmpty)
                  Row(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 0, 15),
                      child: Text(
                        'from project ${widget.superProjectName}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textTheme.headline6!.color,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]),
                if (widget.superProjectName.isEmpty)
                  Card(
                    margin:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    color: Theme.of(context).cardColor,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'CATEGORY',
                            style: TextStyle(
                              color: Theme.of(context).unselectedWidgetColor,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            _category,
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText2!.color,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                if (widget.superProjectName.isEmpty)
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    color: Theme.of(context).cardColor,
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
                                  color:
                                      Theme.of(context).unselectedWidgetColor,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_box),
                                onPressed: () async {
                                  showLabelForm(context, widget.index);
                                },
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            (_labels ?? [])
                                .join(", ")
                                .replaceAll(RegExp("'"), ""),
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText2!.color,
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
          ],
        ),
      ),
    );
  }
}
