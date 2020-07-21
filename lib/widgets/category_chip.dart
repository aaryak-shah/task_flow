import 'package:flutter/material.dart';

class CategoryChips extends StatefulWidget {
  final Function(String) onSelectionChanged;
  const CategoryChips(this.onSelectionChanged);

  @override
  _CategoryChipsState createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  String selectedChoice = '';

  final List<String> categories = [
    'Academics',
    'Personal Development',
    'Chores',
    'Wellness',
    'Recreational',
    // 'Category 6',
    // 'Category 7',
  ];

  List<Widget> _buildChoiceList() {
    List<Widget> choices = List();
    categories.forEach((item) {
      choices.add(ChoiceChip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        selectedColor: Theme.of(context).accentColor,
        padding: EdgeInsets.all(6),
        label: Text(item),
        selected: selectedChoice == item,
        onSelected: (selected) {
          setState(() {
            selectedChoice = item;
            widget.onSelectionChanged(selectedChoice);
          });
        },
      ));
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 10,
      runSpacing: -6,
      children: _buildChoiceList(),
    );
  }
}
