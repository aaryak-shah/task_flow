import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screen to display available settings with their values as stored in SharedPreferences

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  Future<void> _saveSettings(Map<String, bool> settings) async {
    // Arguments => settings: A map having the name of the setting as its key mapped to its value
    //
    // Stores the list of settings to SharedPreferences

    final prefs = await SharedPreferences.getInstance();
    settings.forEach((key, value) {
      prefs.setBool(key, value);
    });
  }

  Future<Map<String, bool>> _loadSettings() async {
    // function to load the settings stored in SharedPreferences 
    // as a map having the name of the setting as its key mapped to its value

    final prefs = await SharedPreferences.getInstance();
    return {
      'showTaskChart': prefs.getBool('showTaskChart') ?? false ,
      'isDarkTheme': prefs.getBool('isDarkTheme') ?? true ,
      'showSeconds': prefs.getBool('showSeconds') ?? false ,
      'setting4': prefs.getBool('setting4') ?? false ,
    };
  }

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // the available settings
  bool _showTaskChart = false;
  bool _isDarkTheme = true;
  bool _showSeconds = false;
  bool _setting4 = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget._loadSettings().then((settings) {
        setState(() {
          // updates this screen with values from SharedPreferences
          _showTaskChart = settings['showTaskChart'];
          _isDarkTheme = settings['isDarkTheme'];
          _showSeconds = settings['showSeconds'];
          _setting4 = settings['setting4'];
        });
      });
    });
  }

  Widget switchTile(
      bool flag, 
      String title, 
      String description, 
      Function changeHandler,
    ) {
    // Arguments => flag: Value of the setting,
    //              title: Title of the setting,
    //              description: Descrtiption of the setting
    //              changeHandler: Function to be called when the value of the switch changes
    //
    // Creates a SwitchListTile for the given setting

    return SwitchListTile.adaptive(
      value: flag,
      onChanged: changeHandler,
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).textTheme.headline6.color),
      ),
      subtitle: Text(
        description,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(20, 30, 20, 5),
            // Appearance section of settings
            child: Text(
              'APPEARANCE',
              style: TextStyle(
                color: Colors.white38,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Column(
            children: <Widget>[
              switchTile(_isDarkTheme, 'Dark Theme', 'Set a dark theme for the app',
                  (val) async {
                setState(() {
                  _isDarkTheme = val;
                });
                Map<String, bool> _settings = {
                  'showTaskChart': _showTaskChart,
                  'isDarkTheme': _isDarkTheme,
                  'showSeconds': _showSeconds,
                  'setting4': _setting4,
                };
                await widget._saveSettings(_settings);
              }),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 30, 20, 5),
            // General section of settings
            child: Text(
              'GENERAL',
              style: TextStyle(
                color: Colors.white38,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Column(
            children: <Widget>[
              switchTile(_showTaskChart, 'Show Chart on Tasks Tab', 'Toggle the chart on the Tasks tab',
                  (val) async {
                setState(() {
                  _showTaskChart = val;
                });
                Map<String, bool> _settings = {
                  'showTaskChart': _showTaskChart,
                  'isDarkTheme': _isDarkTheme,
                  'showSeconds': _showSeconds,
                  'setting4': _setting4,
                };
                await widget._saveSettings(_settings);
              }),
              switchTile(_showSeconds, 'Show Seconds', 'Include seconds in elapsed time',
                  (val) async {
                setState(() {
                  _showSeconds = val;
                });
                Map<String, bool> _settings = {
                  'showTaskChart': _showTaskChart,
                  'isDarkTheme': _isDarkTheme,
                  'showSeconds': _showSeconds,
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
                  'showTaskChart': _showTaskChart,
                  'isDarkTheme': _isDarkTheme,
                  'showSeconds': _showSeconds,
                  'setting4': _setting4,
                };
                await widget._saveSettings(_settings);
              }),
            ],
          ),
        ],
      ),
    );
  }
}
