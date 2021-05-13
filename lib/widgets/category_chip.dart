import 'package:flutter/material.dart';

class CategoryChips extends StatefulWidget {
  // Arguments => sel: The category currently chosen by the user
  //              onSelectionChanged: The function to be called when the user's selection changes
  //
  // Creates a list of Category chips to be shown in modal sheets

  final String sel;
  final Function(String) onSelectionChanged;
  const CategoryChips(this.sel, this.onSelectionChanged);

  @override
  _CategoryChipsState createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  String selectedChoice = '';

  @override
  void initState() {
    selectedChoice = widget.sel;
    super.initState();
  }

  // list of available Categories
  final List<String> categories = [
    'Education',
    'Personal Development',
    'Chores',
    'Wellness',
    'Recreational',
    'Miscellaneous',
  ];

  List<Widget> _buildChoiceList() {
    // function to build a list of Category chip widgets
    final List<Widget> choices = [];
    for (final String item in categories) {
      choices.add(ChoiceChip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        selectedColor: Theme.of(context).accentColor,
        padding: const EdgeInsets.all(6),
        label: Text(
          item,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        selected: selectedChoice == item,
        onSelected: (selected) {
          setState(() {
            selectedChoice = item;
            widget.onSelectionChanged(selectedChoice);
          });
        },
      ));
    }
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: -6,
      children: _buildChoiceList(),
    );
  }
}
