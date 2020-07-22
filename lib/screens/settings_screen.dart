import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/main_drawer.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  Future<void> _saveSettings(Map<String, bool> settings) async {
    final prefs = await SharedPreferences.getInstance();
    settings.forEach((key, value) {
      prefs.setBool(key, value);
    });
  }

  Future<Map<String, bool>> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'setting1': prefs.getBool('setting1') ?? false ,
      'setting2': prefs.getBool('setting2') ?? false ,
      'setting3': prefs.getBool('setting3') ?? false ,
      'setting4': prefs.getBool('setting4') ?? false ,
    };
  }

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _setting1 = false;
  bool _setting2 = false;
  bool _setting3 = false;
  bool _setting4 = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget._loadSettings().then((settings) {
        setState(() {
          _setting1 = settings['setting1'];
          _setting2 = settings['setting2'];
          _setting3 = settings['setting3'];
          _setting4 = settings['setting4'];
        });
      });
    });
  }

  Widget switchTile(
      bool flag, String title, String subtitle, Function changeHandler) {
    return SwitchListTile.adaptive(
      value: flag,
      onChanged: changeHandler,
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).textTheme.headline6.color),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Theme.of(context).textTheme.headline6.color),
      ),
      activeColor: Theme.of(context).accentColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'SETTINGS',
          style: Theme.of(context).appBarTheme.textTheme.headline6,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Your preferences',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                switchTile(_setting1, 'Setting 1', 'Description 1',
                    (val) async {
                  setState(() {
                    _setting1 = val;
                  });
                  Map<String, bool> _settings = {
                    'setting1': _setting1,
                    'setting2': _setting2,
                    'setting3': _setting3,
                    'setting4': _setting4,
                  };
                  await widget._saveSettings(_settings);
                }),
                switchTile(_setting2, 'Setting 2', 'Description 2',
                    (val) async {
                  setState(() {
                    _setting2 = val;
                  });
                  Map<String, bool> _settings = {
                    'setting1': _setting1,
                    'setting2': _setting2,
                    'setting3': _setting3,
                    'setting4': _setting4,
                  };
                  await widget._saveSettings(_settings);
                }),
                switchTile(_setting3, 'Setting 3', 'Description 3',
                    (val) async {
                  setState(() {
                    _setting3 = val;
                  });
                  Map<String, bool> _settings = {
                    'setting1': _setting1,
                    'setting2': _setting2,
                    'setting3': _setting3,
                    'setting4': _setting4,
                  };
                  await widget._saveSettings(_settings);
                }),
                switchTile(_setting4, 'Setting 4', 'Description 4',
                    (val) async {
                  setState(() {
                    _setting4 = val;
                  });
                  Map<String, bool> _settings = {
                    'setting1': _setting1,
                    'setting2': _setting2,
                    'setting3': _setting3,
                    'setting4': _setting4,
                  };
                  await widget._saveSettings(_settings);
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
}
