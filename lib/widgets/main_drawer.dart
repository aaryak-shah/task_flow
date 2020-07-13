import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  Widget buildDrawerTile(IconData icon, String title) {
    return InkWell(
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
        ),
        title: Text(title),
      ),
      onTap: () {
        print(title);
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
                print('Profile');
              },
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Container(
                    height: 200,
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
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
            buildDrawerTile(Icons.perm_contact_calendar, 'Clients'),
            buildDrawerTile(Icons.info, 'About'),
            buildDrawerTile(Icons.feedback, 'Feedback'),
            Spacer(),
            buildDrawerTile(Icons.settings, 'Settings'),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
