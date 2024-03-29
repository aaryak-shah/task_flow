import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/goals.dart';
import '../widgets/app_bar.dart';
import '../widgets/new_labels.dart';
import 'tabs_screen.dart';

// Screen which shows the timer for the currently running goal

void showLabelForm(BuildContext context, int i) {
  // Arguments => context: The context for the modal sheet to be created in,
  //              i: The index of the goal to which the labels are to be added to
  //
  // Opens up a modal sheet to add labels to the current goal

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (_) {
      return GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: NewLabels('goal', i),
      );
    },
  );
}

class CurrentGoalScreen extends StatefulWidget {
  // Arguments => index: The index of the currently running goal

  static const routeName = '/current-goal-screen';
  final int index;
  const CurrentGoalScreen({required this.index});
  @override
  _CurrentGoalScreenState createState() => _CurrentGoalScreenState();
}

class _CurrentGoalScreenState extends State<CurrentGoalScreen> {
  late Goals _provider;
  late Duration _goalTime;
  late String _category;
  late String _title;
  List<String>? _labels;
  bool dummy = false;

  @override
  void didChangeDependencies() {
    _provider = Provider.of<Goals>(context, listen: true);
    final Task _goal = _provider.goals[widget.index];
    _category = _goal.category;
    _labels = _goal.labels;
    _title = _goal.title;
    _goalTime = _goal.goalTime - (DateTime.now().difference(_goal.start));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<Goals>(context);
    return WillPopScope(
      onWillPop: () async {
        await _provider.complete(widget.index);
        Navigator.pushReplacementNamed(
          context,
          TabsScreen.routeName,
          arguments: 1,
        );
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: showAppBar(context),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          children: <Widget>[
            Expanded(
              child: CircularCountDownTimer(
                ringColor: Theme.of(context).cardColor,
                fillColor: Theme.of(context).accentColor,
                isReverse: true,
                textStyle: Theme.of(context).textTheme.headline6!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 50,
                    ),
                strokeWidth: 7.0,
                width: MediaQuery.of(context).size.width / 1.65,
                height: MediaQuery.of(context).size.height / 1.65,
                duration: _goalTime.inSeconds,
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
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            _title.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  Theme.of(context).textTheme.headline6!.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.stop,
                            size: 35,
                            color: Theme.of(context).textTheme.bodyText1!.color,
                          ),
                          onPressed: () async {
                            await _provider.complete(widget.index);
                            Navigator.pushReplacementNamed(
                              context,
                              TabsScreen.routeName,
                              arguments: 1,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
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
            )
          ],
        ),
      ),
    );
  }
}
