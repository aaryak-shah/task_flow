import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BrightnessMode {
  Dark,
  Light,
}

List<Color> darkAccents = [
/*0*/ Colors.lightGreenAccent,
/*2*/ Colors.orangeAccent,
/*3*/ Colors.redAccent,
/*4*/ Colors.purpleAccent,
/*5*/ Colors.blueAccent,
];

List<Color> lightAccents = [
/*0*/ Colors.green,
/*2*/ Colors.deepOrange,
/*3*/ Colors.red,
/*4*/ Colors.purple,
/*5*/ Colors.blue.shade600,
];

class ThemeModel with ChangeNotifier {
  BrightnessMode _mode = BrightnessMode.Dark;
  int _accentIndex = 0;

  ThemeData get currentTheme {
    loadSettings();
    return _mode == BrightnessMode.Dark
        ? ThemeData(
            // dark theme
            brightness: Brightness.dark,
            primaryColor: Color(0xFF121212),
            cardColor: Color(0xFF252525),
            errorColor: Colors.redAccent,
            accentColor: darkAccents[_accentIndex],
            unselectedWidgetColor: Colors.grey,
            appBarTheme: AppBarTheme(
              textTheme: TextTheme(
                headline6: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
                overline: TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            textTheme: TextTheme(
              bodyText1: TextStyle(
                color: Colors.white,
              ),
              bodyText2: TextStyle(
                color: Colors.white54,
              ),
              headline6: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        : ThemeData(
            // dark theme
            brightness: Brightness.light,
            primaryColor: Color(0xFFFAFAFA),
            cardColor: Colors.white,
            errorColor: Colors.red,
            accentColor: lightAccents[_accentIndex],
            unselectedWidgetColor: Color(0xFF4F4F4F),
            appBarTheme: AppBarTheme(
              textTheme: TextTheme(
                headline6: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
                overline: TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            textTheme: TextTheme(
              bodyText1: TextStyle(
                color: Colors.black,
              ),
              bodyText2: TextStyle(
                color: Colors.black87,
              ),
              headline6: TextStyle(
                color: Colors.black,
              ),
            ),
          );
  }

  int get accentIndex => _accentIndex;

  void setAccent(int accIndex) {
    _accentIndex = accIndex;
    notifyListeners();
  }

  void setBrightnessMode(BrightnessMode mode) {
    _mode = mode;
    notifyListeners();
  }

  BoxShadow get bottomFallingShadow {
    return (_mode == BrightnessMode.Dark)
        ? BoxShadow(
            color: Colors.black26,
            blurRadius: 60,
            spreadRadius: 60,
            offset: Offset(0, 60),
          )
        : BoxShadow(
            color: Colors.black12,
            blurRadius: 60,
            spreadRadius: 10,
            offset: Offset(0, 10),
          );
  }

  BoxShadow get topFallingShadow {
    return (_mode == BrightnessMode.Dark)
        ? BoxShadow(
            blurRadius: 30,
            spreadRadius: 30,
            color: Colors.black26,
          )
        : BoxShadow(
            blurRadius: 30,
            spreadRadius: 30,
            color: Colors.black12,
          );
  }

  BoxShadow get cardShadows {
    return (_mode == BrightnessMode.Dark)
        ? BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 3,
            offset: Offset(5, 5),
          )
        : BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(5, 5),
          );
  }

  Future<void> loadSettings() async {
    // function to load the settings stored in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _mode = ((prefs.getBool('isDarkTheme') != null)
        ? ((prefs.getBool('isDarkTheme') ?? true)
            ? BrightnessMode.Dark
            : BrightnessMode.Light)
        : BrightnessMode.Dark);
    _accentIndex = prefs.getInt('accentIndex') ?? 0;
  }

  List<Color> availableAccents() {
    return _mode == BrightnessMode.Dark ? darkAccents : lightAccents;
  }
}
