import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../screens/current_goal_screen.dart';
import '../providers/goals.dart';
import './category_chip.dart';

class NewGoal extends StatefulWidget {
  // Arguments => data: List of data to be set as initial values for the form
  //                    in case an existing goal is restarted instead of creating a new goal
  //
  // Form to add a new goal

  final List<dynamic> data;
  NewGoal(this.data);

  @override
  _NewGoalState createState() => _NewGoalState();
}

class _NewGoalState extends State<NewGoal> {
  String _selectedCategory = '';
  Duration _initTime = Duration(hours: 1);
  final _formKey = GlobalKey<FormState>();

  TextEditingController _titleController = TextEditingController();
  final _titleFocusNode = FocusNode();
  Duration time;

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _titleFocusNode.requestFocus();
    if (widget.data.isNotEmpty) {
      // to populate form with data of existing goal in case the existing goal is restarted
      _titleController = TextEditingController(text: widget.data[0]);
      _selectedCategory = widget.data[1];
      _initTime = widget.data[2];
    } else {
      _initTime = Duration(hours: 1);
    }
    time = _initTime;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDisabled = true;
    var goals = Provider.of<Goals>(context);
    Widget returnCatChips() {
      // function to return Category chips in the modal sheet
      setState(() {
        isDisabled = _selectedCategory.isEmpty;
      });
      return CategoryChips(
        widget.data.isEmpty ? '' : widget.data[1],
        (selectedCategory) {
          setState(() {
            _selectedCategory = selectedCategory;
          });
        },
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      // height: 460,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 100,
            spreadRadius: 100,
            offset: Offset(0, -100),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Theme(
              data: Theme.of(context)
                  .copyWith(primaryColor: Theme.of(context).accentColor),
              child: TextFormField(
                focusNode: _titleFocusNode,
                controller: _titleController,
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return "Enter a title";
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              height: 20,
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Row(
                children: <Widget>[
                  Text(
                    'Categories',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Center(
                child: returnCatChips(),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              height: 20,
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Row(
                children: <Widget>[
                  Text(
                    'Set Goal Time',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              // timer picker spinner widget
              height: 150,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    pickerTextStyle: Theme.of(context).textTheme.headline6,
                  ),
                ),
                child: CupertinoTimerPicker(
                  initialTimerDuration: _initTime,
                  minuteInterval: 10,
                  mode: CupertinoTimerPickerMode.hm,
                  onTimerDurationChanged: (t) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      time = t;
                    });
                  },
                ),
              ),
            ),
            Spacer(),
            ElevatedButton(
              child: Text('START'),
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).accentColor,
                textStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onPressed: (!isDisabled && (time > Duration.zero))
                  ? () async {
                      if (_formKey.currentState.validate()) {
                        // if the form is valid
                        await goals.addGoal(
                          DateTime.now().toString(),
                          _titleController.text,
                          DateTime.now(),
                          _selectedCategory,
                          [],
                          time,
                        );
                        // redirect to the CurrentGoalScreen
                        Navigator.of(context).pushReplacementNamed(
                          CurrentGoalScreen.routeName,
                          arguments: goals.goals.length - 1,
                        );
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
