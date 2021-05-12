import 'package:flutter/material.dart';
import '../widgets/app_bar.dart';

// Screen to display statistics from the Flask API
class StatsScreen extends StatefulWidget {
  static const routeName = '/stats-screen';
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: showAppBar(context),
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
