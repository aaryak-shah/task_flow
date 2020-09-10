import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_flow/providers/theme_switcher.dart';

// Screen to display available settings with their values as stored in SharedPreferences

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  Future<void> _saveSettings(Map<String, dynamic> settings) async {
    // Arguments => settings: A map having the name of the setting as its key mapped to its value
    //
    // Stores the list of settings to SharedPreferences

    final prefs = await SharedPreferences.getInstance();
    settings.forEach((key, value) {
      key != 'accentIndex'
          ? prefs.setBool(key, value)
          : prefs.setInt(key, value);
    });
  }

  Future<Map<String, dynamic>> _loadSettings() async {
    // function to load the settings stored in SharedPreferences
    // as a map having the name of the setting as its key mapped to its value

    final prefs = await SharedPreferences.getInstance();
    return {
      'showTaskChart': prefs.getBool('showTaskChart') ?? false,
      'isDarkTheme': prefs.getBool('isDarkTheme') ?? true,
      'showSeconds': prefs.getBool('showSeconds') ?? false,
      'accentIndex': prefs.getInt('accentIndex') ?? 0,
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
  int _accentIndex = 0;

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
          _accentIndex = settings['accentIndex'];
        });
      });
    });
  }

  void showColorPicker() {
    ThemeModel theme = Provider.of<ThemeModel>(context, listen: false);
    showDialog(
      context: context,
      child: AlertDialog(
        content: BlockPicker(
          pickerColor: Theme.of(context).accentColor,
          availableColors: theme.availableAccents(),
          onColorChanged: (selectedColor) {
            setState(() {
              int index = theme.availableAccents().indexOf(selectedColor);
              theme.setAccent(index);
              _accentIndex = index;
            });
          },
        ),
      ),
    );
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
                color: Theme.of(context).unselectedWidgetColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Column(
            children: <Widget>[
              switchTile(
                  _isDarkTheme, 'Dark Theme', 'Set a dark theme for the app',
                  (val) async {
                setState(() {
                  _isDarkTheme = val;
                });
                Map<String, dynamic> _settings = {
                  'showTaskChart': _showTaskChart,
                  'isDarkTheme': _isDarkTheme,
                  'showSeconds': _showSeconds,
                  'accentIndex': _accentIndex,
                };
                await widget._saveSettings(_settings);
              }),
              ListTile(
                title: Text(
                  'Accent Color',
                ),
                subtitle: Text(
                  'Select an accent color for the app',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                trailing: RaisedButton(
                  child: Text(
                    'CHANGE',
                  ),
                  onPressed: () {
                    showColorPicker();
                    Map<String, dynamic> _settings = {
                      'showTaskChart': _showTaskChart,
                      'isDarkTheme': _isDarkTheme,
                      'showSeconds': _showSeconds,
                      'accentIndex': _accentIndex,
                    };
                    widget._saveSettings(_settings);
                  },
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 30, 20, 5),
            // General section of settings
            child: Text(
              'GENERAL',
              style: TextStyle(
                color: Theme.of(context).unselectedWidgetColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Column(
            children: <Widget>[
              switchTile(_showTaskChart, 'Show Chart on Tasks Tab',
                  'Toggle the chart on the Tasks tab', (val) async {
                setState(() {
                  _showTaskChart = val;
                });
                Map<String, dynamic> _settings = {
                  'showTaskChart': _showTaskChart,
                  'isDarkTheme': _isDarkTheme,
                  'showSeconds': _showSeconds,
                  'accentIndex': _accentIndex,
                };
                await widget._saveSettings(_settings);
              }),
              switchTile(_showSeconds, 'Show Seconds',
                  'Include seconds in elapsed time', (val) async {
                setState(() {
                  _showSeconds = val;
                });
                Map<String, dynamic> _settings = {
                  'showTaskChart': _showTaskChart,
                  'isDarkTheme': _isDarkTheme,
                  'showSeconds': _showSeconds,
                  'accentIndex': _accentIndex,
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
