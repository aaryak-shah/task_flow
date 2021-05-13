import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/providers/settings.dart';
import 'package:task_flow/providers/theme_switcher.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void showColorPicker() {
    final ThemeModel theme = Provider.of<ThemeModel>(context, listen: false);
    showDialog(
      builder: (context) => AlertDialog(
        content: BlockPicker(
          pickerColor: Theme.of(context).accentColor,
          availableColors: theme.availableAccents(),
          onColorChanged: (selectedColor) async {
            final int index = theme.availableAccents().indexOf(selectedColor);
            final settings = Provider.of<Settings>(context, listen: false);
            await settings.setAccentIndex(index);
            theme.setAccent(index);
          },
        ),
      ),
      context: context,
    );
  }

  Widget switchTile(
    // ignore: avoid_positional_boolean_parameters
    bool flag,
    String title,
    String description,
    void Function(bool) changeHandler,
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
        style: TextStyle(color: Theme.of(context).textTheme.headline6!.color),
      ),
      subtitle: Text(
        description,
        style: TextStyle(color: Theme.of(context).textTheme.headline6!.color),
      ),
      activeColor: Theme.of(context).accentColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(builder: (context, settings, _) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            'SETTINGS',
            style: Theme.of(context).appBarTheme.textTheme!.headline6,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 5),
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
                switchTile(settings.isDarkTheme, 'Dark Theme',
                    'Set a dark theme for the app', (val) async {
                  await settings.setIsDarkTheme(val);
                  Provider.of<ThemeModel>(context, listen: false)
                      .setBrightnessMode(
                          val ? BrightnessMode.dark : BrightnessMode.light);
                }),
                ListTile(
                  title: const Text(
                    'Accent Color',
                  ),
                  subtitle: Text(
                    'Select an accent color for the app',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      showColorPicker();
                    },
                    child: const Text(
                      'CHANGE',
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 5),
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
                switchTile(
                    settings.shortTaskChart,
                    'Show Shorter Chart on Tasks Tab',
                    'Reduce the height of the chart on the Tasks tab',
                    (val) async {
                  await settings.setShortTaskChart(val);
                }),
                switchTile(settings.showSeconds, 'Show Seconds',
                    'Include seconds in elapsed time', (val) async {
                  await settings.setShowSeconds(val);
                }),
              ],
            ),
          ],
        ),
      );
    });
  }
}
