import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/providers/projects.dart';

class ClientsScreen extends StatefulWidget {
  static const routeName = '/clients';
  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
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
          return ListTile(
            leading: Text(
              clients[index].key.length <= 40
                  ? clients[index].key
                  : (clients[index].key.substring(0, 40) + '...'),
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyText1.color,
                  fontSize: 20),
            ),
            trailing: Text(clients[index].value.toString()),
          );
        },
        itemCount: clients.length,
      ),
    );
  }
}
