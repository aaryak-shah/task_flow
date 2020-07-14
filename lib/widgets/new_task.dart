import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
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
              controller: _titleController,
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
            CategoryChips(
              (selectedList) {
                setState(() {
                  _selectedCategories = selectedList;
                });
              },
            ),
            RaisedButton(
              child: Text('START'),
              color: Theme.of(context).accentColor,
              textColor: Theme.of(context).primaryColor,
              onPressed: () {
                final tasks = Provider.of<Tasks>(context, listen: false);

                tasks.addTask(DateTime.now().toString(), _titleController.text,
                    DateTime.now(), _selectedCategories, [], null);
                print(tasks.tasks[0].title);
              },
            )
          ],
        ),
      ),
    );
  }
}
