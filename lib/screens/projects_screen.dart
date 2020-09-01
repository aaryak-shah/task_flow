import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/providers/project.dart';
import 'package:task_flow/providers/projects.dart';
import 'package:task_flow/screens/current_project_screen.dart';

// Screen to display all the projects in the past week

class ProjectsScreen extends StatefulWidget {
  @override
  _ProjectsScreenState createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  bool loaded = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      setState(() {
        loaded = false;
      });

      Projects projects = Provider.of<Projects>(context, listen: false);
      for (Project project in projects.projects) {
        print('loading');
        await project.loadData();
      }
      setState(() {
        loaded = true;
        print("loaded");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loaded) {
      print('running this');
      Projects projects = Provider.of<Projects>(context, listen: false);
      List<Project> sortedProjects = projects.projects;
      sortedProjects.sort(
          (prev, next) => prev.lastActive.isBefore(next.lastActive) ? 1 : 0);
      Project latestProject = sortedProjects.isEmpty ? null : sortedProjects[0];
      return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  // sortedProjects
                  if (index == 0) {
                    return Container(
                      height: 200,
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/card_bg.png'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(10)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            highlightColor: Colors.transparent,
                            splashColor:
                                Theme.of(context).accentColor.withOpacity(0.4),
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  CurrentProjectScreen.routeName,
                                  arguments: sortedProjects[index].id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LAST ACTIVE: ' +
                                        DateFormat('dd MMM yy')
                                            .format(latestProject.lastActive),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  Text(
                                    latestProject.name,
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                  Text(
                                    latestProject.cardTags(),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        latestProject.deadlineString,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                      Text(
                                        latestProject.earnings,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Color(0xFF262525),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            highlightColor: Colors.transparent,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  CurrentProjectScreen.routeName,
                                  arguments: sortedProjects[index].id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LAST ACTIVE: ' +
                                        DateFormat('dd MMM yy').format(
                                            sortedProjects[index].lastActive),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  Text(
                                    sortedProjects[index].name,
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                  Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        sortedProjects[index].deadlineString,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                      Text(
                                        sortedProjects[index].earnings,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
                itemCount: sortedProjects.length,
              ),
            )
          ],
        ),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
