import 'package:flutter/material.dart';

class CategoryChips extends StatefulWidget {
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


  final List<String> categories = [
    'Education',
    'Personal Development',
    'Chores',
    'Wellness',
    'Recreational',
    'Miscellaneous',
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
