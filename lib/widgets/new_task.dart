import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tasks.dart';
import '../screens/current_task_screen.dart';
import 'category_chip.dart';

class NewTask extends StatefulWidget {
  // Arguments => data: List of data to be set as initial values for the form
  //                    in case an existing task is restarted instead of creating a new task
  //
  // Form to add a new task

  final List<dynamic> data;
  const NewTask(this.data);
  @override
  _NewTaskState createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  String _selectedCategory = '';
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  final _titleFocusNode = FocusNode();

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.data.isNotEmpty) {
      // to populate form with data of existing task in case the existing task is restarted
      _titleController = TextEditingController(text: widget.data[0] as String?);
      _selectedCategory = widget.data[1] as String;
    }
    _titleFocusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDisabled = true;
    final tasks = Provider.of<Tasks>(context);
    Widget returnCatChips() {
      // function to return Category chips in the modal sheet
      setState(() {
        _selectedCategory.isNotEmpty ? isDisabled = false : isDisabled = true;
      });
      return CategoryChips(
        widget.data.isEmpty ? '' : widget.data[1] as String,
        (selectedCategory) {
          setState(() {
            _selectedCategory = selectedCategory;
          });
        },
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      // height: 460,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: const [
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
                  if (value == null || value.isEmpty) {
                    return "Enter a title";
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              height: 20,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Row(
                children: const <Widget>[
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
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).accentColor,
                textStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onPressed: (!isDisabled)
                  ? () async {
                      if (_formKey.currentState!.validate()) {
                        // if the form is valid
                        await tasks.addTask(
                          DateTime.now().toString(),
                          _titleController.text,
                          DateTime.now(),
                          _selectedCategory,
                          [],
                        );
                        // redirect to the CurrentTaskScreen with appropriate arguments
                        Navigator.of(context).pushReplacementNamed(
                            CurrentTaskScreen.routeName,
                            arguments: {
                              'index': tasks.tasks.length - 1,
                              'wasSuspended': false,
                              'superProjectName': '',
                              'superProjectId': '',
                            });
                      }
                    }
                  : null,
              child: const Text('START'),
            ),
          ],
        ),
      ),
    );
  }
}
