import 'package:flutter/material.dart';
import '../widgets/app_bar.dart';

class StatsScreen extends StatefulWidget {
  static const routeName = '/stats-screen';
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar(context),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
