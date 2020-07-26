import 'package:flutter/material.dart';
import 'package:task_flow/screens/stats_screen.dart';
import '../screens/settings_screen.dart';

class MainDrawer extends StatelessWidget {
  Widget buildDrawerTile(
      BuildContext context, IconData icon, String title, String route) {
    return InkWell(
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
        ),
        title: Text(title),
      ),
      onTap: () {
        Navigator.of(context).pushNamed(route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
              },
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Container(
                    height: 200,
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Image.asset('assets/images/drawer_bg.png'),
                    ),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(
                        'assets/images/default_pfp.png',
                      ),
                    ),
                    title: Text(
                      'Aaryak Shah',
                    ),
                    subtitle: Text(
                      'profile',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            buildDrawerTile(context,Icons.perm_contact_calendar, 'Clients', "/"),
            buildDrawerTile(context,Icons.equalizer, 'Stats', StatsScreen.routeName),
            buildDrawerTile(context,Icons.info, 'About', "/"),
            buildDrawerTile(context,Icons.feedback, 'Feedback', "/"),
            Spacer(),
            buildDrawerTile(context,Icons.settings, 'Settings', SettingsScreen.routeName),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
