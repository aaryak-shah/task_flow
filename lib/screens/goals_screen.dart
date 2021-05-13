import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/providers/settings.dart';

import '../providers/goals.dart';
import '../widgets/plus_btn_controllers.dart';

// Screen to display all the goals in the past week

class GoalsScreen extends StatefulWidget {
  static const routeName = '/goals-screen';
  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  Widget build(BuildContext context) {
    final goals = Provider.of<Goals>(context);

    return goals.goals.isEmpty
        ? Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
          )
        : Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'YOUR GOALS',
                        style: TextStyle(
                          color: Theme.of(context).unselectedWidgetColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        '',
                        style: TextStyle(
                          color: Theme.of(context).unselectedWidgetColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    // ListView builder to display goal tiles
                    itemCount: goals.recentGoals.reversed.length,
                    itemBuilder: (ctx, index) {
                      final g = goals.recentGoals.reversed.toList()[index];
                      return Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: ListTile(
                          leading: IconButton(
                            icon: Icon(
                              Icons.refresh,
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color,
                            ),
                            onPressed: () {
                              // opens the modal sheet to restart this goal
                              showEditGoalForm(
                                  context, [g.title, g.category, g.goalTime]);
                            },
                          ),
                          title: Text(
                            g.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            goals.categoryString(g.id),
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          trailing: Consumer<Settings>(
                            builder: (context, settings, _) => Text(
                              g.getTimeString('goal', showSeconds: settings.showSeconds),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}
