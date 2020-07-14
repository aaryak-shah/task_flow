import 'package:flutter/material.dart';

class CategoryChips extends StatefulWidget {
  final Function(List<String>) onSelectionChanged;
  const CategoryChips(this.onSelectionChanged);

  @override
  _CategoryChipsState createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  List<String> selectedChoices = List();

  final List<String> categories = [
    'Category 1',
    'Category 2',
    'Category 3',
    'Category 4',
    'Category 5',
    'Category 6',
    'Category 7'
  ];

  _buildChoiceList() {
    List<Widget> choices = List();
    categories.forEach((item) {
      choices.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: ChoiceChip(
          selectedColor: Theme.of(context).accentColor,
          padding: EdgeInsets.all(6),
          label: Text(item),
          selected: selectedChoices.contains(item),
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(item)
                  ? selectedChoices.remove(item)
                  : selectedChoices.add(item);
              widget.onSelectionChanged(selectedChoices);
            });
          },
        ),
      ));
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      children: _buildChoiceList(),
    );
  }
}
