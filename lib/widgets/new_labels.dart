import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/goals.dart';
import '../providers/projects.dart';
import '../providers/tasks.dart';

List<String> _labels = [];

class NewLabels extends StatefulWidget {
  // Arguments => mode: The mode in which labels are to be added, either 'tasks' or 'goals',
  //              taskIndex: The index of the task (or goal) in the _tasks (or _goals)
  //                         list to which labels are to be added
  //
  // Modal sheet to add labels to a task or a goal (depending on mode)

  final String mode;
  final int taskIndex;
  const NewLabels(this.mode, this.taskIndex);

  @override
  _NewLabelsState createState() => _NewLabelsState();
}

class _NewLabelsState extends State<NewLabels> {
  List<String> _selectedLabels = [];
  Widget labelChips(Function(List<String>) onSelectionChanged) {
    // Arguments => onSelectionChanged: Function to be called when the user's selection changes
    //
    // returns a set of label chips to be displayed on the modal sheet

    final List<String> labels = _labels;
    List<Widget> _buildChoiceList() {
      // function to create a list of label chips
      final List<Widget> choices = [];
      for (final String item in labels) {
        choices.add(ChoiceChip(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          selectedColor: Theme.of(context).accentColor,
          padding: const EdgeInsets.all(6),
          label: Text(item),
          selected: _selectedLabels.contains(item),
          onSelected: (selected) {
            setState(() {
              if (!_selectedLabels.contains(item)) {
                _selectedLabels.add(item);
              } else {
                _selectedLabels.remove(item);
              }
              onSelectionChanged(_selectedLabels);
            });
          },
        ));
      }
      return choices;
    }

    return Wrap(
      spacing: 10,
      runSpacing: -6,
      children: _buildChoiceList(),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      switch (widget.mode) {
        case 'task':
          {
            Provider.of<Tasks>(context)
                .availableLabels
                .then((value) => _labels = value);
            break;
          }
        case 'goal':
          {
            Provider.of<Goals>(context)
                .availableLabels
                .then((value) => _labels = value);
            break;
          }
        case 'project':
          {
            Provider.of<Goals>(context)
                .availableLabels
                .then((value) => _labels = value);
            break;
          }
      }

      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<Tasks>(context);
    final goals = Provider.of<Goals>(context);
    final projects = Provider.of<Projects>(context);
    Widget returnLabelChips() {
      // function that returns the label chips
      return labelChips(
        (selectedLabels) {
          setState(() {
            _selectedLabels = selectedLabels;
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
                onFieldSubmitted: (val) {
                  setState(() {
                    if (val.trim() != '') {
                      _labels.add(val.trim());
                      _selectedLabels.add(val.trim());
                    }
                    _titleController.clear();
                  });
                },
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Add a New Label',
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
                    'Your Labels',
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
                child: returnLabelChips(),
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
              onPressed: () async {
                switch (widget.mode) {
                  case 'task':
                    {
                      await tasks.addLabels(
                          widget.taskIndex, _selectedLabels, _labels);
                      break;
                    }
                  case 'goal':
                    {
                      await goals.addLabels(
                          widget.taskIndex, _selectedLabels, _labels);
                      break;
                    }
                  case 'project':
                    {
                      await projects.addLabels(
                          widget.taskIndex, _selectedLabels, _labels);
                      break;
                    }
                }
                Navigator.of(context).pop();
              },
              child: const Text('ADD'),
            ),
          ],
        ),
      ),
    );
  }
}
