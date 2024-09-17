import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tekkers/providers/theme_manager.dart';

class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Themes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Select a Theme'),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              children: [
                _themeButton(context, 'Default', Colors.blue, Colors.white, ThemeMode.light),
                _themeButton(context, 'Dark Theme', Colors.black, Colors.white, ThemeMode.dark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeButton(BuildContext context, String label, Color color1, Color color2, ThemeMode themeMode) {
    return GestureDetector(
      onTap: () {
        // Apply the theme via ThemeManager
        Provider.of<ThemeManager>(context, listen: false).setTheme(themeMode);
        Navigator.pop(context);  // Return to the previous screen after theme selection
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}