import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeManager() {
    _loadThemeFromPrefs();
  }

  void setTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    _saveThemeToPrefs();
    notifyListeners();
  }

  void _saveThemeToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', _themeMode == ThemeMode.light ? 'light' : 'dark');
  }

  void _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString('theme');
    if (theme != null) {
      _themeMode = theme == 'light' ? ThemeMode.light : ThemeMode.dark;
    }
    notifyListeners();
  }
}