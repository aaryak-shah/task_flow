import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tasks.dart';
import '../providers/goals.dart';

List<String> _labels = [];

class NewLabels extends StatefulWidget {
  // Arguments => mode: The mode in which labels are to be added, either 'tasks' or 'goals',
  //              taskIndex: The index of the task (or goal) in the _tasks (or _goals)
  //                         list to which labels are to be added
  //
  // Modal sheet to add labels to a task or a goal (depending on mode)

  final String mode;
  final int taskIndex;
  NewLabels(this.mode, this.taskIndex);

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
      List<Widget> choices = List();
      labels.forEach((item) {
        choices.add(ChoiceChip(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          selectedColor: Theme.of(context).accentColor,
          padding: EdgeInsets.all(6),
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
      });
      return choices;
    }

    return Wrap(
      alignment: WrapAlignment.start,
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
          //
        }
      }

      widget.mode == 'task'
          ? Provider.of<Tasks>(context)
              .availableLabels
              .then((value) => _labels = value)
          : Provider.of<Goals>(context)
              .availableLabels
              .then((value) => _labels = value);

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
                decoration: InputDecoration(
                  labelText: 'Add a New Label',
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
            Spacer(),
            RaisedButton(
              child: Text('ADD'),
              color: Theme.of(context).accentColor,
              textColor: Theme.of(context).primaryColor,
              onPressed: () async {
                widget.mode == 'task'
                    ? await tasks.addLabels(
                        widget.taskIndex, _selectedLabels, _labels)
                    : await goals.addLabels(
                        widget.taskIndex, _selectedLabels, _labels);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
