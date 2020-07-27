import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_bar.dart';
import '../providers/goals.dart';
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
        child: NewLabels('goal', i),
        behavior: HitTestBehavior.opaque,
      );
    },
  );
}

class CurrentGoalScreen extends StatefulWidget {
  static const routeName = '/current-goal-screen';
  final int index;
  CurrentGoalScreen({this.index});
  @override
  _CurrentGoalScreenState createState() => _CurrentGoalScreenState();
}

class _CurrentGoalScreenState extends State<CurrentGoalScreen> {
  var _provider;
  Duration _goalTime;
  String _category;
  String _title;
  List<String> _labels;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      var _provider = Provider.of<Goals>(context, listen: true);
      Task _goal = _provider.goals[widget.index];
      _category = _goal.category;
      _labels = _goal.labels;
      _title = _goal.title;
      _goalTime = _goal.goalTime - (DateTime.now().difference(_goal.start));
      print(
          'state variables: provider:$_provider goal:$_goal title:$_title goaltime:$_goalTime');
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<Goals>(context);
    return WillPopScope(
      onWillPop: () async {
        await _provider.complete(widget.index);
        Navigator.pushReplacementNamed(context, '/');
        return true;
      },
      child: Scaffold(
        appBar: showAppBar(context),
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: CircularCountDownTimer(
                color: Color(0xFF252525),
                fillColor: Theme.of(context).accentColor,
                isReverse: true,
                textStyle: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 50,
                    ),
                strokeWidth: 7.0,
                width: MediaQuery.of(context).size.width / 1.5,
                height: MediaQuery.of(context).size.height / 1.5,
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
                        IconButton(
                          icon: Icon(
                            Icons.stop,
                            size: 35,
                            color: Theme.of(context).errorColor,
                          ),
                          onPressed: () async {
                            await _provider.complete(widget.index);
                            Navigator.pushReplacementNamed(context, '/');
                          },
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
