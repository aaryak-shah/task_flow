import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/providers/project.dart';
import 'package:task_flow/providers/projects.dart';
import 'package:task_flow/providers/task.dart';
import 'package:task_flow/screens/current_task_screen.dart';
import 'package:task_flow/screens/tabs_screen.dart';
import 'package:task_flow/widgets/new_labels.dart';
import '../widgets/app_bar.dart';

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
        child: NewLabels('project', i),
        behavior: HitTestBehavior.opaque,
      );
    },
  );
}

class CurrentProjectScreen extends StatefulWidget {
  static const routeName = '/current-project-screen';
  final int index;
  final String projectId;

  CurrentProjectScreen({this.projectId, this.index});

  @override
  _CurrentProjectScreenState createState() => _CurrentProjectScreenState();
}

class _CurrentProjectScreenState extends State<CurrentProjectScreen> {
  bool loaded = false, _isInit = true;
  Project project;

  @override
  void initState() {
    Future.microtask(() async {
      final directory = await getApplicationDocumentsDirectory();
      File f = File(
          '${directory.path}/st_${widget.projectId.replaceAll(new RegExp(r'[:. \-]'), "")}.csv');
      if (!f.existsSync()) {
        f.writeAsStringSync('');
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      project = Provider.of<Projects>(context).projects.firstWhere((proj) {
        return proj.id == widget.projectId;
      });
      _isInit = false;
    }
    setState(() {
      loaded = false;
    });
    Future.delayed(Duration.zero, () async {
      await project.loadData();
      await project.syncEngine();
      setState(() {
        loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    void newSubTask(String name) {
      final key = GlobalKey<FormState>();

      TextEditingController titleController = TextEditingController(text: name);
      showDialog(
        context: context,
        child: AlertDialog(
          title: Text('New Subtask'),
          content: Form(
            key: key,
            child: Theme(
              data: Theme.of(context)
                  .copyWith(primaryColor: Theme.of(context).accentColor),
              child: TextFormField(
                controller: titleController,
                autofocus: true,
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Enter a Title';
                  }
                },
                decoration: InputDecoration(labelText: 'Title'),
              ),
            ),
          ),
          actions: [
            FlatButton(
              child: Text('START'),
              onPressed: () async {
                if (key.currentState.validate()) {
                  await project.addSubTask(
                    ctx: context,
                    id: DateTime.now().toString(),
                    start: DateTime.now(),
                    title: titleController.text,
                  );
                  Navigator.of(context).pushReplacementNamed(
                    CurrentTaskScreen.routeName,
                    arguments: {
                      'index': (project.subTasks.length - 1),
                      'wasSuspended': false,
                      'superProjectName': project.name,
                      'superProjectId': project.id
                    },
                  );
                }
              },
            )
          ],
        ),
      );
    }

    if (loaded) {
      return WillPopScope(
        onWillPop: () async {
          await Provider.of<Projects>(context, listen: false).syncEngine();
          Navigator.pushReplacementNamed(
            context,
            TabsScreen.routeName,
            arguments: 2,
          );
          return true;
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: showAppBar(context),
          floatingActionButton: FloatingActionButton(
            child: Icon(
              Icons.add,
              size: 35,
            ),
            backgroundColor: Theme.of(context).cardColor,
            foregroundColor: Theme.of(context).accentColor,
            onPressed: () {
              newSubTask('');
            },
          ),
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).cardColor,
                  image: DecorationImage(
                    image: AssetImage('assets/images/card_bg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Text(
                      project.cardTags(requireLabels: false),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Text(
                          'LABELS: ' + project.labels.join(', '),
                          style: Theme.of(context).textTheme.bodyText1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Icon(Icons.add),
                          onTap: () {
                            showLabelForm(context, widget.index);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.fromLTRB(10, 0, 5, 10),
                    width: MediaQuery.of(context).size.width * 0.463,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).cardColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Earnings',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        Spacer(),
                        Text(
                          project.earnings,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1.color,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.fromLTRB(5, 0, 10, 10),
                    width: MediaQuery.of(context).size.width * 0.463,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).cardColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        Spacer(),
                        Text(
                          project.deadlineString,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1.color,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'YOUR SUBTASKS - ${project.workingDuration.inHours}h ${project.workingDuration.inMinutes.remainder(60)}min',
                style: TextStyle(
                  color: Colors.white38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    Task current = project.subTasks[index];
                    return ListTile(
                      leading: current.end == null
                          ? IconButton(
                              icon: Icon(Icons.play_arrow),
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  CurrentTaskScreen.routeName,
                                  arguments: {
                                    'index': index,
                                    'wasSuspended': false,
                                    'superProjectName': project.name,
                                    'superProjectId': project.id,
                                  },
                                );
                              },
                            )
                          : IconButton(
                              icon: Icon(Icons.refresh),
                              onPressed: () {
                                newSubTask(current.title);
                              },
                            ),
                      title: Text(current.title),
                      trailing: Text(current.getTimeString('run')),
                    );
                  },
                  itemCount:
                      project.subTasks == null ? 0 : project.subTasks.length,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
