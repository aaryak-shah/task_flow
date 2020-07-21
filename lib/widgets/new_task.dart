import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/providers/task.dart';
import 'package:task_flow/screens/current_task.dart';

import '../providers/tasks.dart';
import './category_chip.dart';

class NewTask extends StatefulWidget {
  @override
  _NewTaskState createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  List<String> _selectedCategories = [];
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _titleFocusNode = FocusNode();

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _titleFocusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDisabled = true;
    var tasks = Provider.of<Tasks>(context);
    Widget returnCatChips() {
      setState(() {
        _selectedCategories.isNotEmpty ? isDisabled = false : isDisabled = true;
      });
      return CategoryChips(
        (selectedList) {
          setState(() {
            _selectedCategories = selectedList;
          });
        },
      );
    }

    return Container(
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextFormField(
              focusNode: _titleFocusNode,
              controller: _titleController,
              validator: (value) {
                if (value.isEmpty) {
                  return "Enter a title";
                }
              },
              decoration: InputDecoration(
                labelText: 'Title',
              ),
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
            returnCatChips(),
            RaisedButton(
              child: Text('START'),
              color: Theme.of(context).accentColor,
              textColor: Theme.of(context).primaryColor,
              onPressed: (!isDisabled)
                  ? () async {
                      if (_formKey.currentState.validate()) {
                        await tasks.addTask(
                            DateTime.now().toString(),
                            _titleController.text,
                            DateTime.now(),
                            _selectedCategories,
                            [],
                            null);
                        Navigator.of(context).pushReplacementNamed(
                          CurrentTaskScreen.routeName,
                          arguments: tasks.tasks.length -1,
                        );
                      }
                    }
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
