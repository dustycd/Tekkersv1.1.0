import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  ThemeData _themeData;

  ThemeManager(this._themeData);

  ThemeData get themeData => _themeData;

  setTheme(ThemeData theme) async {
    _themeData = theme;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme == ThemeData.light() ? 'light' : 'dark');
  }

  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTheme = prefs.getString('theme');
    if (savedTheme != null) {
      _themeData = savedTheme == 'light' ? ThemeData.light() : ThemeData.dark();
    } else {
      _themeData = ThemeData.light(); // Default to light theme
    }
    notifyListeners();
  }
}