import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings with ChangeNotifier {
  bool _shortTaskChart;
  bool _isDarkTheme;
  bool _showSeconds;
  int _accentIndex;

  Future<SharedPreferences> get preferences async {
    return await SharedPreferences.getInstance();
  }

  Settings() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await preferences;

    _shortTaskChart = prefs.getBool('shortTaskChart') ?? false;
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? true;
    _showSeconds = prefs.getBool('showSeconds') ?? false;
    _accentIndex = prefs.getInt('accentIndex') ?? 0;

    notifyListeners();
  }

  Future<void> setShortTaskChart(bool value) async {
    final prefs = await preferences;
    prefs.setBool('shortTaskChart', value);
    _shortTaskChart = value;
    notifyListeners();
  }

  Future<void> setIsDarkTheme(bool value) async {
    final prefs = await preferences;
    prefs.setBool('isDarkTheme', value);
    _isDarkTheme = value;
    notifyListeners();
  }

  Future<void> setShowSeconds(bool value) async {
    final prefs = await preferences;
    prefs.setBool('showSeconds', value);
    _showSeconds = value;
    notifyListeners();
  }

  Future<void> setAccentIndex(int value) async {
    final prefs = await preferences;
    prefs.setInt('accentIndex', value);
    _accentIndex = value;
    notifyListeners();
  }

  bool get shortTaskChart => _shortTaskChart ?? false;
  bool get isDarkTheme => _isDarkTheme ?? true;
  bool get showSeconds => _showSeconds ?? false;
  int get accentIndex => _accentIndex ?? 0;
}
