import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/projects.dart';
import '../providers/settings.dart';
import '../widgets/client_details.dart';

void showClientDetails(
    BuildContext context, String clientName, double earning, String time) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (_) {
      return GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: ClientDetails(
          clientName: clientName,
          earning: earning,
          time: time,
        ),
      );
    },
  );
}

class ClientsScreen extends StatefulWidget {
  static const routeName = '/clients';
  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String timeString(int time, {required bool showSeconds}) {
    String h, m, s;
    final int hrs = (time / 3600).floor();
    final int mins = (time / 60).floor();
    final int seconds = time % 60;
    (hrs / 10).floor() == 0 ? h = '0$hrs:' : h = '$hrs:';
    (mins / 10).floor() == 0 ? m = '0$mins' : m = mins.toString();
    (seconds / 10).floor() == 0 ? s = ':0$seconds' : s = ':$seconds';
    return h + m + (showSeconds ? s : '');
  }

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, List<double>>> clients =
        Provider.of<Projects>(context).clients.entries.toList();
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'CLIENTS',
          style: Theme.of(context).appBarTheme.textTheme!.headline6,
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final int time = clients[index].value[0].toInt();
          final double earning = clients[index].value[1];

          return Consumer<Settings>(
            builder: (context, settings, _) => InkWell(
              onTap: () {
                showClientDetails(context, clients[index].key, earning,
                    timeString(time, showSeconds: settings.showSeconds));
              },
              child: ListTile(
                title: Text(
                  clients[index].key.length <= 40
                      ? clients[index].key
                      : ('${clients[index].key.substring(0, 40)}...'),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).accentColor,
                        fontSize: 20,
                      ),
                ),
                subtitle: Text("₹${earning.toStringAsFixed(2)}"),
                trailing: Text(
                  timeString(time, showSeconds: settings.showSeconds),
                ),
              ),
            ),
          );
        },
        itemCount: clients.length,
      ),
    );
  }
}
