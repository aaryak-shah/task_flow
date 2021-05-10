import 'package:flutter/material.dart';

class LabelChips extends StatefulWidget {
  // Arguments => onSelectionChanged: The function to be called when the user's selection changes,
  //              availableLabels: List of available labels
  //
  // Creates a list of Label chips to be shown in modal sheets

  final Function(List<String>) onSelectionChanged;
  final List<String> availableLabels;
  const LabelChips(this.onSelectionChanged, this.availableLabels);


  @override
  _LabelChipsState createState() => _LabelChipsState();
}

class _LabelChipsState extends State<LabelChips> {
  List<String> selectedLabels = [];
  final List<String> labels = [];

  List<Widget> _buildChoiceList() {
    // function to build a list of Label chip widgets
    List<Widget> choices =[];
    labels.forEach((item) {
      choices.add(ChoiceChip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        selectedColor: Theme.of(context).accentColor,
        padding: EdgeInsets.all(6),
        label: Text(item),
        selected: selectedLabels.contains(item),
        onSelected: (selected) {
          setState(() {
            selectedLabels.add(item);
            widget.onSelectionChanged(selectedLabels);
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
