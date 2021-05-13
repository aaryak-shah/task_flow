import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/models/project.dart';
import 'package:task_flow/providers/projects.dart';
import 'package:task_flow/screens/current_project_screen.dart';

class ClientDetails extends StatelessWidget {
  final String clientName;
  final double earning;
  final String time;

  const ClientDetails({
    required this.clientName,
    required this.earning,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final List<Project> projects = Provider.of<Projects>(context, listen: false)
        .projectsByClient(clientName);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Text(clientName),
          Text("₹${earning.toStringAsFixed(2)} | $time"),
          Expanded(
            child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (ctx, index) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      CurrentProjectScreen.routeName,
                      arguments: {
                        'projectId': projects[index].id,
                        'index': Provider.of<Projects>(context, listen: false)
                            .projectIndex(projects[index].id),
                        'isFromClients': true,
                      },
                    );
                  },
                  child: ListTile(
                    title: Text(
                      projects[index].name,
                    ),
                    subtitle: Text(
                      "Last Active: ${DateFormat('dd MMM yy')
                              .format(projects[index].lastActive)}",
                    ),
                    trailing: Text(
                      projects[index].earnings,
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
