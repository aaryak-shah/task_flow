import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/providers/projects.dart';
import 'package:task_flow/providers/settings.dart';

class ClientsScreen extends StatefulWidget {
  static const routeName = '/clients';
  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String timeString(int time, bool showSeconds) {
    String h, m, s;
    int hrs = (time / 3600).floor();
    int mins = (time / 60).floor();
    int seconds = time % 60;
    (hrs / 10).floor() == 0
        ? h = '0' + hrs.toString() + ':'
        : h = hrs.toString() + ':';
    (mins / 10).floor() == 0 ? m = '0' + mins.toString() : m = mins.toString();
    (seconds / 10).floor() == 0
        ? s = ':0' + seconds.toString()
        : s = ':' + seconds.toString();
    return h + m + (showSeconds ? s : '');
  }

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, int>> clients =
        Provider.of<Projects>(context).clients.entries.toList();
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'CLIENTS',
          style: Theme.of(context).appBarTheme.textTheme.headline6,
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          int time = clients[index].value;
          return ListTile(
            leading: Text(
              clients[index].key.length <= 40
                  ? clients[index].key
                  : (clients[index].key.substring(0, 40) + '...'),
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyText1.color,
                    fontSize: 20,
                  ),
            ),
            trailing: Consumer<Settings>(
              builder: (context, settings, _) => Text(
                timeString(time, settings.showSeconds),
              ),
            ),
          );
        },
        itemCount: clients.length,
      ),
    );
  }
}
