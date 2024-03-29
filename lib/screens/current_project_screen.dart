import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/project.dart';
import '../models/task.dart';
import '../providers/projects.dart';
import '../providers/settings.dart';
import '../providers/theme_switcher.dart';
import '../widgets/app_bar.dart';
import '../widgets/new_labels.dart';
import 'current_task_screen.dart';
import 'tabs_screen.dart';

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
        child: NewLabels('project', i),
      );
    },
  );
}

class CurrentProjectScreen extends StatefulWidget {
  static const routeName = '/current-project-screen';

  final int index;
  final String projectId;
  final bool isFromClients;

  const CurrentProjectScreen({
    required this.projectId,
    required this.index,
    this.isFromClients = false,
  });

  @override
  _CurrentProjectScreenState createState() => _CurrentProjectScreenState();
}

class _CurrentProjectScreenState extends State<CurrentProjectScreen> {
  bool loaded = false, _isInit = true, _isCompleted = false;
  late Project project;

  @override
  void initState() {
    Future.microtask(() async {
      final directory = await getApplicationDocumentsDirectory();
      final File f = File(
          '${directory.path}/st_${widget.projectId.replaceAll(RegExp(r'[:. \-]'), "")}.csv');
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
      final TextEditingController titleController =
          TextEditingController(text: name);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('New Subtask'),
          content: Form(
            key: key,
            child: Theme(
              data: Theme.of(context)
                  .copyWith(primaryColor: Theme.of(context).accentColor),
              child: TextFormField(
                controller: titleController,
                autofocus: true,
                validator: (value) {
                  if (value!.trim().isEmpty) {
                    return 'Enter a Title';
                  }
                },
                decoration: const InputDecoration(labelText: 'Title'),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (key.currentState!.validate()) {
                  await project.addSubTask(
                    ctx: context,
                    id: DateTime.now().toString(),
                    start: DateTime.now(),
                    title: titleController.text,
                  );
                  Navigator.of(context).pushReplacementNamed(
                    CurrentTaskScreen.routeName,
                    arguments: {
                      'index': project.subTasks.length - 1,
                      'wasSuspended': false,
                      'superProjectName': project.name,
                      'superProjectId': project.id
                    },
                  );
                }
              },
              child: const Text('START'),
            )
          ],
        ),
      );
    }

    if (loaded && !_isCompleted) {
      final ThemeModel themeModel = Provider.of<ThemeModel>(context);
      return WillPopScope(
        onWillPop: () async {
          await Provider.of<Projects>(context, listen: false).syncEngine();
          widget.isFromClients
              ? Navigator.pop(context)
              : Navigator.pushReplacementNamed(
                  context,
                  TabsScreen.routeName,
                  arguments: 2,
                );
          return true;
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: showAppBar(context),
          ),
          floatingActionButton: project.end == null
              ? FloatingActionButton(
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: Theme.of(context).accentColor,
                  onPressed: () {
                    newSubTask('');
                  },
                  child: const Icon(
                    Icons.add,
                    size: 35,
                  ),
                )
              : null,
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).cardColor,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/card_bg.png'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [themeModel.cardShadows],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          project.name,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1!.color,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        if (project.end == null)
                          IconButton(
                              icon: const Icon(Icons.stop),
                              onPressed: () async {
                                setState(() {
                                  _isCompleted = true;
                                });
                                await Provider.of<Projects>(context,
                                        listen: false)
                                    .complete(widget.index);
                                setState(() {
                                  _isCompleted = false;
                                });
                              })
                      ],
                    ),
                    Text(
                      project.cardTags(requireLabels: false),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          'LABELS: ${project.labels.join(', ')}',
                          style: Theme.of(context).textTheme.bodyText1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        if (project.end == null)
                          GestureDetector(
                            onTap: () {
                              showLabelForm(context, widget.index);
                            },
                            child: const Icon(Icons.add),
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
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.fromLTRB(10, 0, 5, 10),
                    width: MediaQuery.of(context).size.width * 0.463,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).cardColor,
                      boxShadow: [themeModel.cardShadows],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Earnings',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        const Spacer(),
                        Text(
                          project.earnings,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1!.color,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.fromLTRB(5, 0, 10, 10),
                    width: MediaQuery.of(context).size.width * 0.463,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).cardColor,
                      boxShadow: [themeModel.cardShadows],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        const Spacer(),
                        Text(
                          project.deadlineString,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1!.color,
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
              const SizedBox(
                height: 10,
              ),
              Text(
                'YOUR SUBTASKS - ${project.workingDuration.inHours}h ${project.workingDuration.inMinutes.remainder(60)}min',
                style: const TextStyle(
                  color: Colors.white38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    final Task current = project.subTasks[index];
                    return ListTile(
                      leading: project.end == null
                          ? (current.end == null
                              ? IconButton(
                                  icon: const Icon(Icons.play_arrow),
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
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () {
                                    newSubTask(current.title);
                                  },
                                ))
                          : null,
                      title: Text(current.title),
                      trailing: Consumer<Settings>(
                        builder: (context, settings, _) => Text(
                          current.end == null
                              ? current.getTimeString('run',
                                  showSeconds: settings.showSeconds)
                              : 'Completed',
                        ),
                      ),
                    );
                  },
                  itemCount: project.subTasks.length,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
